<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function users(): JsonResponse
    {
        $items = User::query()
            ->orderBy('id')
            ->get(['id', 'phone', 'name', 'disabled', 'verify_status']);

        return response()->json([
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function verifyQueue(): JsonResponse
    {
        $items = User::query()
            ->where('verify_status', '!=', 'approved')
            ->orderBy('id')
            ->get(['id', 'phone', 'name', 'verify_status']);

        return response()->json([
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function updateVerify(Request $request, int $uid): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', 'string', 'in:pending,approved,rejected'],
        ]);

        $user = User::find($uid);
        if (!$user) {
            return response()->json(['message' => 'user not found'], 404);
        }

        $user->verify_status = $data['status'];
        $user->save();

        return response()->json(['ok' => true]);
    }

    public function disable(int $uid): JsonResponse
    {
        $user = User::find($uid);
        if (!$user) {
            return response()->json(['message' => 'user not found'], 404);
        }

        $user->disabled = true;
        $user->save();

        return response()->json(['ok' => true]);
    }
}
