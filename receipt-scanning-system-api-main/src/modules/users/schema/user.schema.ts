import { Schema } from 'mongoose';

export const UserSchema = new Schema(
    {
        user_username: { type: String, unique: true },
        user_password: String,
        user_display_name: String,
        user_avatar: String,
    },
    {
        timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' },
    },
);
