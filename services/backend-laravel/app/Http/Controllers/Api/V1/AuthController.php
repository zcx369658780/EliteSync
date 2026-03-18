<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'phone' => ['required', 'string', 'max:32', 'unique:users,phone'],
            'password' => ['required', 'string', Password::min(8)->letters()->numbers()],
            'name' => ['nullable', 'string', 'max:255'],
        ]);

        $user = User::create([
            'phone' => $data['phone'],
            'name' => $data['name'] ?? null,
            'password' => Hash::make($data['password']),
        ]);

        $token = $user->createToken('mobile-access')->plainTextToken;

        return response()->json([
            'user' => [
                'id' => $user->id,
                'phone' => $user->phone,
                'name' => $user->name,
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
            ],
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }
}
