<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\AdminController;
use App\Http\Controllers\Api\V1\MatchController;
use App\Http\Controllers\Api\V1\MessageController;
use App\Http\Controllers\Api\V1\QuestionnaireController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
        Route::post('/refresh', [AuthController::class, 'refresh'])->middleware('auth:sanctum');
    });

    Route::prefix('questionnaire')->middleware('auth:sanctum')->group(function () {
        Route::get('/questions', [QuestionnaireController::class, 'questions']);
        Route::post('/questions/replace', [QuestionnaireController::class, 'replaceQuestion']);
        Route::post('/answers', [QuestionnaireController::class, 'submitAnswers']);
        Route::get('/progress', [QuestionnaireController::class, 'progress']);
        Route::get('/profile', [QuestionnaireController::class, 'profile']);
    });

    // 兼容旧客户端路径
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/questions', [QuestionnaireController::class, 'questions']);
        Route::post('/questions/answers', [QuestionnaireController::class, 'submitAnswers']);
    });

    Route::middleware('auth:sanctum')->group(function () {
        Route::prefix('matches')->group(function () {
            Route::get('/current', [MatchController::class, 'current']);
            Route::post('/confirm', [MatchController::class, 'confirm']);
            Route::get('/history', [MatchController::class, 'history']);
        });

        // 兼容旧设计中的单数路径
        Route::prefix('match')->group(function () {
            Route::get('/current', [MatchController::class, 'current']);
            Route::post('/like', [MatchController::class, 'confirm']);
            Route::get('/history', [MatchController::class, 'history']);
        });

        Route::prefix('messages')->group(function () {
            Route::post('', [MessageController::class, 'send']);
            Route::get('', [MessageController::class, 'list']);
            Route::post('/read/{messageId}', [MessageController::class, 'markRead']);
            Route::get('/ws/{userId}', [MessageController::class, 'websocketStub']);
        });

        Route::prefix('admin')->middleware('admin.phone')->group(function () {
            Route::get('/users', [AdminController::class, 'users']);
            Route::post('/users/{uid}/disable', [AdminController::class, 'disable']);
            Route::get('/verify-queue', [AdminController::class, 'verifyQueue']);
            Route::post('/verify/{uid}', [AdminController::class, 'updateVerify']);
            Route::post('/dev/run-matching', [AdminController::class, 'devRunMatching']);
            Route::post('/dev/release-drop', [AdminController::class, 'devReleaseDrop']);
        });
    });
});
