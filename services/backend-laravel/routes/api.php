<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\AdminController;
use App\Http\Controllers\Api\V1\AppVersionController;
use App\Http\Controllers\Api\V1\GeoController;
use App\Http\Controllers\Api\V1\AstroProfileController;
use App\Http\Controllers\Api\V1\FrontendTelemetryController;
use App\Http\Controllers\Api\V1\ModerationController;
use App\Http\Controllers\Api\V1\HomeController;
use App\Http\Controllers\Api\V1\MatchController;
use App\Http\Controllers\Api\V1\MbtiProfileController;
use App\Http\Controllers\Api\V1\MessageController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\StatusPostController;
use App\Http\Controllers\Api\V1\QuestionnaireController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::prefix('app')->group(function () {
        Route::get('/health', [AppVersionController::class, 'health']);
        Route::get('/version/check', [AppVersionController::class, 'check']);
    });

    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:auth');
        Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:auth');
        Route::post('/refresh', [AuthController::class, 'refresh'])->middleware('auth:sanctum');
        Route::post('/password', [AuthController::class, 'changePassword'])->middleware('auth:sanctum');
        Route::delete('/account', [AuthController::class, 'deleteSelf'])->middleware('auth:sanctum');
    });

    Route::prefix('questionnaire')->middleware('auth:sanctum')->group(function () {
        Route::get('/questions', [QuestionnaireController::class, 'questions']);
        Route::post('/questions/replace', [QuestionnaireController::class, 'replaceQuestion']);
        Route::post('/answers', [QuestionnaireController::class, 'submitAnswers']);
        // Legacy compatibility endpoints (old Android/Flutter builds)
        Route::post('/submit', [QuestionnaireController::class, 'submitAnswers']);
        Route::post('/draft', [QuestionnaireController::class, 'saveDraftLegacy']);
        Route::post('/reset', [QuestionnaireController::class, 'reset']);
        Route::get('/progress', [QuestionnaireController::class, 'progress']);
        Route::get('/profile', [QuestionnaireController::class, 'profile']);
    });

    // 兼容旧客户端路径
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/questions', [QuestionnaireController::class, 'questions']);
        Route::post('/questions/answers', [QuestionnaireController::class, 'submitAnswers']);
    });

    Route::middleware('auth:sanctum')->group(function () {
        Route::prefix('telemetry')->group(function () {
            Route::post('/events', [FrontendTelemetryController::class, 'store']);
            Route::post('/match-explanation-preview-opened', [FrontendTelemetryController::class, 'store']);
            Route::post('/first-chat-entry', [FrontendTelemetryController::class, 'store']);
            Route::post('/match-feedback-submitted', [FrontendTelemetryController::class, 'store']);
        });

        Route::prefix('profile')->group(function () {
            Route::get('/basic', [ProfileController::class, 'basic']);
            Route::post('/basic', [ProfileController::class, 'saveBasic']);
            Route::post('/city', [ProfileController::class, 'saveCity']);
            Route::get('/astro/summary', [AstroProfileController::class, 'showSummary']);
            Route::get('/astro/chart', [AstroProfileController::class, 'showChart']);
            Route::get('/astro', [AstroProfileController::class, 'show']);
            Route::post('/astro', [AstroProfileController::class, 'save']);
            Route::get('/mbti/quiz', [MbtiProfileController::class, 'quiz']);
            Route::post('/mbti/submit', [MbtiProfileController::class, 'submit']);
            Route::get('/mbti/result', [MbtiProfileController::class, 'result']);
        });

        Route::prefix('matches')->group(function () {
            Route::get('/current', [MatchController::class, 'current']);
            Route::post('/confirm', [MatchController::class, 'confirm']);
            Route::get('/history', [MatchController::class, 'history']);
            Route::get('/{targetUserId}/explanation', [MatchController::class, 'explanationByTarget'])
                ->whereNumber('targetUserId');
        });

        // 兼容旧设计中的单数路径
        Route::prefix('match')->group(function () {
            Route::get('/current', [MatchController::class, 'current']);
            Route::post('/like', [MatchController::class, 'confirm']);
            Route::get('/history', [MatchController::class, 'history']);
            Route::get('/{targetUserId}/explanation', [MatchController::class, 'explanationByTarget'])
                ->whereNumber('targetUserId');
        });

        Route::prefix('messages')->group(function () {
            Route::post('', [MessageController::class, 'send'])->middleware('throttle:messages');
            Route::get('', [MessageController::class, 'list'])->middleware('throttle:messages');
            Route::post('/read/{messageId}', [MessageController::class, 'markRead']);
            Route::get('/ws/{userId}', [MessageController::class, 'websocketStub']);
        });

        Route::prefix('moderation')->group(function () {
            Route::post('/reports', [ModerationController::class, 'report']);
            Route::post('/reports/{reportId}/appeal', [ModerationController::class, 'appeal']);
            Route::get('/blocks', [ModerationController::class, 'blocks']);
            Route::post('/blocks', [ModerationController::class, 'block']);
            Route::delete('/blocks/{blockedUserId}', [ModerationController::class, 'unblock'])
                ->whereNumber('blockedUserId');
        });

        Route::prefix('home')->group(function () {
            Route::get('/banner', [HomeController::class, 'banner']);
            Route::get('/shortcuts', [HomeController::class, 'shortcuts']);
            Route::get('/feed', [HomeController::class, 'feed']);
        });

        Route::prefix('status')->group(function () {
            Route::get('/posts', [StatusPostController::class, 'index']);
            Route::post('/posts', [StatusPostController::class, 'store']);
            Route::delete('/posts/{postId}', [StatusPostController::class, 'destroy'])
                ->whereNumber('postId');
        });

        Route::prefix('discover')->group(function () {
            Route::get('/feed', [HomeController::class, 'discoverFeed']);
        });

        Route::get('/content/{contentId}', [HomeController::class, 'content']);

        Route::prefix('geo')->group(function () {
            Route::get('/places', [GeoController::class, 'places']);
        });

        Route::prefix('admin')->middleware('admin.phone')->group(function () {
            Route::get('/users', [AdminController::class, 'users']);
            Route::get('/reports', [AdminController::class, 'reports']);
            Route::get('/reports/{reportId}', [AdminController::class, 'reportDetail'])
                ->whereNumber('reportId');
            Route::post('/reports/{reportId}/action', [AdminController::class, 'reportAction'])
                ->whereNumber('reportId');
            Route::get('/questionnaire/quality-stats', [AdminController::class, 'questionQualityStats']);
            Route::post('/questionnaire/prune-low-drop', [AdminController::class, 'pruneLowDropQuestions']);
            Route::post('/users/{uid}/disable', [AdminController::class, 'disable']);
            Route::get('/verify-queue', [AdminController::class, 'verifyQueue']);
            Route::post('/verify/{uid}', [AdminController::class, 'updateVerify']);
            Route::post('/dev/run-matching', [AdminController::class, 'devRunMatching']);
            Route::post('/dev/release-drop', [AdminController::class, 'devReleaseDrop']);
            Route::get('/dev/matching-debug', [AdminController::class, 'devMatchingDebugStatus']);
            Route::post('/dev/matching-debug', [AdminController::class, 'devMatchingDebugSwitch']);
        });
    });
})->middleware('secure.transport');
