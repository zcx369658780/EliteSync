<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\ChineseZodiacService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
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
            'user' => [
                'id' => $user->id,
                'phone' => $user->phone,
                'name' => $user->name,
                'birthday' => optional($user->birthday)->format('Y-m-d'),
                'zodiac_animal' => $user->zodiac_animal,
                'gender' => $user->gender,
                'city' => $user->city,
                'relationship_goal' => $user->relationship_goal,
                'realname_verified' => (bool) $user->realname_verified,
            ],
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
            'user' => [
                'id' => $user->id,
                'phone' => $user->phone,
                'name' => $user->name,
                'birthday' => optional($user->birthday)->format('Y-m-d'),
                'zodiac_animal' => $user->zodiac_animal,
                'gender' => $user->gender,
                'city' => $user->city,
                'relationship_goal' => $user->relationship_goal,
                'realname_verified' => (bool) $user->realname_verified,
            ],
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
            'user' => [
                'id' => $user->id,
                'phone' => $user->phone,
                'name' => $user->name,
                'birthday' => optional($user->birthday)->format('Y-m-d'),
                'zodiac_animal' => $user->zodiac_animal,
                'gender' => $user->gender,
                'city' => $user->city,
                'relationship_goal' => $user->relationship_goal,
                'realname_verified' => (bool) $user->realname_verified,
            ],
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
}
