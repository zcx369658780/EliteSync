<?php

namespace Database\Seeders;

use App\Models\QuestionnaireQuestion;
use Illuminate\Database\Seeder;

class QuestionnaireQuestionSeeder extends Seeder
{
    public function run(): void
    {
        $items = [
            [
                'question_key' => 'life_value_1',
                'content' => '你更看重伴侣的哪一点？',
                'question_type' => 'single_choice',
                'options' => ['三观契合', '情绪稳定', '共同成长'],
                'sort_order' => 1,
                'enabled' => true,
            ],
            [
                'question_key' => 'date_style_1',
                'content' => '第一次约会你偏向哪种方式？',
                'question_type' => 'single_choice',
                'options' => ['咖啡聊天', '散步看展', '一起吃饭'],
                'sort_order' => 2,
                'enabled' => true,
            ],
            [
                'question_key' => 'communication_1',
                'content' => '当出现分歧时，你通常会怎么做？',
                'question_type' => 'single_choice',
                'options' => ['先冷静再沟通', '当下直接沟通', '写下来再交流'],
                'sort_order' => 3,
                'enabled' => true,
            ],
        ];

        foreach ($items as $item) {
            QuestionnaireQuestion::updateOrCreate(
                ['question_key' => $item['question_key']],
                $item,
            );
        }
    }
}
