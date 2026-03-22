<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function basic(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'phone' => $user->phone,
            'birthday' => optional($user->birthday)->format('Y-m-d'),
            'gender' => $user->gender,
            'city' => $user->city,
            'relationship_goal' => $user->relationship_goal,
            'realname_verified' => (bool) $user->realname_verified,
        ]);
    }

    public function saveBasic(Request $request): JsonResponse
    {
        $data = $request->validate([
            'birthday' => ['nullable', 'date_format:Y-m-d'],
            'name' => ['nullable', 'string', 'max:255'],
            'gender' => ['required', 'in:male,female'],
            'city' => ['required', 'string', 'max:64'],
            'relationship_goal' => ['required', 'in:marriage,dating,friendship'],
        ]);

        $user = $request->user();
        if (array_key_exists('birthday', $data)) {
            $user->birthday = $data['birthday'] ?: null;
        }
        if (array_key_exists('name', $data)) {
            $user->name = $data['name'] ?: null;
        }
        $user->gender = $data['gender'];
        $user->city = $data['city'];
        $user->relationship_goal = $data['relationship_goal'];
        $user->save();

        return response()->json([
            'ok' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'phone' => $user->phone,
                'birthday' => optional($user->birthday)->format('Y-m-d'),
                'gender' => $user->gender,
                'city' => $user->city,
                'relationship_goal' => $user->relationship_goal,
                'realname_verified' => (bool) $user->realname_verified,
            ],
        ]);
    }
}
