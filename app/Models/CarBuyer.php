<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CarBuyer extends Model
{
    protected $fillable = [
        'first_name',
        'last_name',
        'email',
        'phone',
        'desired_car_model',
        'budget',
        'additional_notes',
    ];
}
