<?php

namespace Tests\Unit;

use App\Services\MediaStateMachine;
use Tests\TestCase;

class MediaStateMachineTest extends TestCase
{
    public function test_media_status_machine_covers_expected_states(): void
    {
        $machine = new MediaStateMachine();

        $this->assertSame(
            ['pending', 'uploading', 'uploaded', 'processing', 'ready', 'failed', 'blocked', 'deleted'],
            $machine->statuses()
        );

        $this->assertTrue($machine->canTransition('pending', 'uploading'));
        $this->assertTrue($machine->canTransition('uploaded', 'processing'));
        $this->assertTrue($machine->canTransition('failed', 'uploading'));
        $this->assertFalse($machine->canTransition('deleted', 'ready'));
        $this->assertSame('pending', $machine->normalize('unknown'));
        $this->assertSame('ready', $machine->normalize('READY'));
    }
}
