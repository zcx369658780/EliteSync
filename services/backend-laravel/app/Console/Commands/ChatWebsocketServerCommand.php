<?php

namespace App\Console\Commands;

use App\Models\ChatMessage;
use Illuminate\Console\Command;
use Throwable;
use Workerman\Connection\TcpConnection;
use Workerman\Timer;
use Workerman\Worker;

class ChatWebsocketServerCommand extends Command
{
    protected $signature = 'chat:ws {--host=0.0.0.0} {--port=8081} {--poll=2}';

    protected $description = 'Run lightweight chat websocket gateway based on DB polling';

    private function parseUserIdFromPath(string $uri): ?int
    {
        $path = parse_url($uri, PHP_URL_PATH) ?: '/';

        if (preg_match('#^/api/v1/messages/ws/(\d+)$#', $path, $m)) {
            return (int) $m[1];
        }
        if (preg_match('#^/ws/(\d+)$#', $path, $m)) {
            return (int) $m[1];
        }

        return null;
    }

    private function prepareWorkermanArgv(): void
    {
        $argv = $_SERVER['argv'] ?? [];
        if (!is_array($argv)) {
            $argv = [];
        }

        $lifecycleCommands = ['start', 'stop', 'restart', 'reload', 'status', 'connections'];
        $hasLifecycle = false;
        foreach ($argv as $arg) {
            if (in_array((string) $arg, $lifecycleCommands, true)) {
                $hasLifecycle = true;
                break;
            }
        }

        // Workerman requires a lifecycle command; default to foreground start for systemd.
        if (!$hasLifecycle) {
            $patched = [$argv[0] ?? 'artisan', 'start'];
            $_SERVER['argv'] = $patched;
            $_SERVER['argc'] = 2;
            $GLOBALS['argv'] = $patched;
            $GLOBALS['argc'] = 2;
        }
    }

    public function handle(): int
    {
        $host = (string) $this->option('host');
        $port = (int) $this->option('port');
        $pollInterval = max(1, (int) $this->option('poll'));

        $gateway = new Worker("websocket://{$host}:{$port}");
        $gateway->count = 1;
        $gateway->name = 'EliteSyncChatGateway';

        $gateway->onConnect = function (TcpConnection $connection): void {
            $connection->userId = null;
            $connection->lastSeenId = 0;
        };

        $gateway->onWebSocketConnect = function (TcpConnection $connection, $request): void {
            $uri = $request->server['request_uri'] ?? '/';
            $userId = $this->parseUserIdFromPath($uri);

            if (!$userId) {
                $connection->close();

                return;
            }

            $connection->userId = $userId;
            $connection->lastSeenId = (int) (ChatMessage::query()
                ->where('receiver_id', $userId)
                ->max('id') ?? 0);

            $connection->send(json_encode([
                'type' => 'connected',
                'user_id' => $userId,
                'last_seen_id' => $connection->lastSeenId,
            ], JSON_UNESCAPED_UNICODE));
        };

        $gateway->onMessage = function (TcpConnection $connection, string $payload): void {
            if (trim($payload) === 'ping') {
                $connection->send('pong');
            }
        };

        $gateway->onWorkerStart = function () use ($gateway, $pollInterval): void {
            Timer::add($pollInterval, function () use ($gateway): void {
                /** @var TcpConnection $connection */
                foreach ($gateway->connections as $connection) {
                    $userId = (int) ($connection->userId ?? 0);
                    if ($userId <= 0) {
                        continue;
                    }

                    try {
                        $messages = ChatMessage::query()
                            ->where('receiver_id', $userId)
                            ->where('id', '>', (int) ($connection->lastSeenId ?? 0))
                            ->orderBy('id')
                            ->limit(50)
                            ->get(['id', 'sender_id', 'receiver_id', 'content', 'created_at']);
                    } catch (Throwable) {
                        continue;
                    }

                    foreach ($messages as $message) {
                        $connection->send(json_encode([
                            'type' => 'message',
                            'id' => $message->id,
                            'sender_id' => $message->sender_id,
                            'receiver_id' => $message->receiver_id,
                            'content' => $message->content,
                            'created_at' => optional($message->created_at)->toIso8601String(),
                        ], JSON_UNESCAPED_UNICODE));
                        $connection->lastSeenId = $message->id;
                    }
                }
            });
        };

        $this->info("Chat websocket gateway running at ws://{$host}:{$port}");
        $this->info('Supported paths: /api/v1/messages/ws/{userId} or /ws/{userId}');
        $this->prepareWorkermanArgv();
        Worker::runAll();

        return self::SUCCESS;
    }
}
