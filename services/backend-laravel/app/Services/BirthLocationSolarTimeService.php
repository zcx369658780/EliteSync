<?php

namespace App\Services;

use Carbon\CarbonImmutable;

class BirthLocationSolarTimeService
{
    /**
     * @param array<string,mixed> $payload
     * @return array{
     *   effective_birthday:string,
     *   effective_birth_time:string,
     *   true_solar_time:string,
     *   location_shift_minutes:int,
     *   location_source:string,
     *   location_label:string
     * }
     */
    public function resolve(array $payload): array
    {
        $birthday = trim((string) ($payload['birthday'] ?? ''));
        $birthTime = trim((string) ($payload['birth_time'] ?? ''));
        $birthPlace = trim((string) ($payload['birth_place'] ?? ''));
        $birthLat = $this->toFloat($payload['birth_lat'] ?? null);
        $birthLng = $this->toFloat($payload['birth_lng'] ?? null);

        if ($birthday === '' || $birthTime === '') {
            return [
                'effective_birthday' => $birthday,
                'effective_birth_time' => $birthTime,
                'true_solar_time' => $birthTime,
                'location_shift_minutes' => 0,
                'longitude_offset_minutes' => 0,
                'equation_of_time_minutes' => 0,
                'location_source' => 'missing_birthday_or_birth_time',
                'location_label' => $birthPlace,
                'position_signature' => $this->buildPositionSignature($birthPlace, $birthLat, $birthLng, $birthTime),
            ];
        }

        try {
            $source = CarbonImmutable::createFromFormat('Y-m-d H:i', $birthday.' '.$birthTime, 'Asia/Shanghai');
        } catch (\Throwable) {
            return [
                'effective_birthday' => $birthday,
                'effective_birth_time' => $birthTime,
                'true_solar_time' => $birthTime,
                'location_shift_minutes' => 0,
                'longitude_offset_minutes' => 0,
                'equation_of_time_minutes' => 0,
                'location_source' => 'invalid_birth_datetime',
                'location_label' => $birthPlace,
                'position_signature' => $this->buildPositionSignature($birthPlace, $birthLat, $birthLng, $birthTime),
            ];
        }

        $longitudeOffsetMinutes = 0;
        $equationOfTimeMinutes = 0;
        $locationSource = 'default_meridian_120E';
        if ($birthLng !== null) {
            $longitudeOffsetMinutes = (int) round(($birthLng - 120.0) * 4.0);
            $locationSource = 'longitude_based';
        } elseif ($birthLat !== null) {
            $locationSource = 'latitude_only_no_shift';
        } elseif ($birthPlace !== '') {
            $locationSource = 'birth_place_without_coordinates';
        } else {
            $locationSource = 'no_location';
        }

        $birthdayDate = CarbonImmutable::createFromFormat('Y-m-d', $birthday, 'Asia/Shanghai');
        if ($birthdayDate) {
            $dayOfYear = ((int) $birthdayDate->format('z')) + 1;
            $b = deg2rad((360.0 / 364.0) * ($dayOfYear - 81));
            $equationOfTimeMinutes = (int) round(9.87 * sin(2 * $b) - 7.53 * cos($b) - 1.5 * sin($b));
        }

        $shiftMinutes = $longitudeOffsetMinutes + $equationOfTimeMinutes;
        $adjusted = $source->addMinutes($shiftMinutes);

        return [
            'effective_birthday' => $adjusted->toDateString(),
            'effective_birth_time' => $adjusted->format('H:i'),
            'true_solar_time' => $adjusted->format('H:i'),
            'location_shift_minutes' => $shiftMinutes,
            'longitude_offset_minutes' => $longitudeOffsetMinutes,
            'equation_of_time_minutes' => $equationOfTimeMinutes,
            'location_source' => $locationSource,
            'location_label' => $birthPlace,
            'position_signature' => $this->buildPositionSignature($birthPlace, $birthLat, $birthLng, $birthTime),
        ];
    }

    private function toFloat(mixed $value): ?float
    {
        if ($value === null) {
            return null;
        }
        if (is_float($value) || is_int($value)) {
            return (float) $value;
        }
        $trimmed = trim((string) $value);
        return $trimmed === '' ? null : (float) $trimmed;
    }

    private function buildPositionSignature(string $birthPlace, ?float $birthLat, ?float $birthLng, string $birthTime): string
    {
        $lat = $birthLat === null ? 'null' : number_format($birthLat, 4, '.', '');
        $lng = $birthLng === null ? 'null' : number_format($birthLng, 4, '.', '');

        return hash('crc32b', implode('|', [$birthPlace, $lat, $lng, $birthTime]));
    }
}
