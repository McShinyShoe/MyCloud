<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Note extends Model
{
    use HasFactory;

    // Allow mass assignment for the following fields
    protected $fillable = ['title', 'content', 'user_id'];

    // Define relationship to the User model
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
