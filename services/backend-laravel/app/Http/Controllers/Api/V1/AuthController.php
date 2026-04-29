<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserAstroProfile;
use App\Services\ChineseZodiacService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    private function normalizeBirthPlace(mixed $value): ?string
    {
        $candidate = trim((string) $value);
        return $candidate !== '' ? $candidate : null;
    }

    private function resolveBirthTime(User $user): ?string
    {
        $profile = UserAstroProfile::query()
            ->where('user_id', (int) $user->id)
            ->first();

        return $profile?->birth_time;
    }

    /**
     * @return array<string, mixed>
     */
    private function userPayload(User $user): array
    {
        $profile = UserAstroProfile::query()
            ->where('user_id', (int) $user->id)
            ->first();

        $birthPlace = $this->normalizeBirthPlace($user->private_birth_place)
            ?? $this->normalizeBirthPlace($profile?->birth_place);
        $birthLat = $user->private_birth_lat ?? $profile?->birth_lat;
        $birthLng = $user->private_birth_lng ?? $profile?->birth_lng;

        return [
            'id' => $user->id,
            'phone' => $user->phone,
            'name' => $user->name,
            'birthday' => optional($user->birthday)->format('Y-m-d'),
            'birth_time' => $this->resolveBirthTime($user),
            'zodiac_animal' => $user->zodiac_animal,
            'gender' => $user->gender,
            'city' => $user->city,
            'relationship_goal' => $user->relationship_goal,
            'birth_place' => $birthPlace,
            'private_birth_place' => $birthPlace,
            'birth_lat' => $birthLat,
            'private_birth_lat' => $birthLat,
            'birth_lng' => $birthLng,
            'private_birth_lng' => $birthLng,
            'realname_verified' => (bool) $user->realname_verified,
        ];
    }

    public function register(Request $request, ChineseZodiacService $zodiacService): JsonResponse
    {
        $data = $request->validate([
            'phone' => ['required', 'string', 'max:32', 'unique:users,phone'],
            'password' => ['required', 'string', Password::min(8)->letters()->numbers()],
            'name' => ['nullable', 'string', 'max:255'],
            'birthday' => ['nullable', 'date_format:Y-m-d'],
            'realname_verified' => ['required', 'accepted'],
        ]);

        $user = User::create([
            'phone' => $data['phone'],
            'name' => $data['name'] ?? null,
            'birthday' => $data['birthday'] ?? null,
            'zodiac_animal' => $zodiacService->fromBirthdayString($data['birthday'] ?? null),
            'realname_verified' => true,
            'password' => Hash::make($data['password']),
        ]);

        $token = $user->createToken('mobile-access')->plainTextToken;

        return response()->json([
            'user' => $this->userPayload($user),
            'access_token' => $token,
            'token_type' => 'Bearer',
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'phone' => ['required', 'string', 'max:32'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('phone', $data['phone'])->first();
        if (!$user || !Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'phone' => ['手机号或密码错误。'],
            ]);
        }
        if ($user->disabled) {
            return response()->json(['message' => '账号已被禁用。'], 403);
        }

        $token = $user->createToken('mobile-access')->plainTextToken;

        return response()->json([
            'user' => $this->userPayload($user),
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    public function refresh(Request $request): JsonResponse
    {
        $user = $request->user();
        $user->currentAccessToken()?->delete();
        $token = $user->createToken('mobile-access')->plainTextToken;

        return response()->json([
            'user' => $this->userPayload($user),
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    public function changePassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'current_password' => ['required', 'string'],
            'new_password' => ['required', 'string', 'different:current_password', Password::min(8)->letters()->numbers(), 'confirmed'],
        ]);

        $user = $request->user();
        if (!$user || !Hash::check($data['current_password'], $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['当前密码不正确。'],
            ]);
        }

        $user->password = Hash::make($data['new_password']);
        $user->save();

        return response()->json([
            'ok' => true,
            'message' => '密码已更新',
        ]);
    }

    public function deleteSelf(Request $request): JsonResponse
    {
        $data = $request->validate([
            'current_password' => ['required', 'string'],
        ]);

        $user = $request->user();
        if (!$user || !Hash::check($data['current_password'], $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['当前密码不正确。'],
            ]);
        }

        $phone = (string) $user->phone;
        $name = (string) ($user->name ?? '');
        $allowSyntheticCleanup = str_starts_with($phone, '90')
            || (bool) $user->is_synthetic
            || str_starts_with($name, 'Smoke');

        if (!$allowSyntheticCleanup) {
            return response()->json([
                'message' => 'only smoke/synthetic accounts can be deleted by this endpoint',
            ], 403);
        }

        $user->tokens()->delete();
        $user->delete();

        return response()->json([
            'ok' => true,
            'message' => '账号已删除',
        ]);
    }
}
