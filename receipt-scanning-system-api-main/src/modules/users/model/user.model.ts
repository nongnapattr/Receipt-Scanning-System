import { Timestamps } from './../../shared/interfaces/timestamps.model';

export class UserModel extends Timestamps {
    user_username: string;
    user_password: string;
    user_display_name?: string;
    user_avatar?: string;
}
