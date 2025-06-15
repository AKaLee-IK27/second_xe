-- Insert mock users
INSERT INTO "User" (
    id,
    auth_id,
    email,
    full_name,
    role,
    is_verified,
    created_at,
    updated_at
) VALUES
    (
        '00000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000001',
        'user1@example.com',
        'John Doe',
        'user',
        true,
        NOW(),
        NOW()
    ),
    (
        '00000000-0000-0000-0000-000000000002',
        '00000000-0000-0000-0000-000000000002',
        'user2@example.com',
        'Jane Smith',
        'user',
        true,
        NOW(),
        NOW()
    ),
    (
        '00000000-0000-0000-0000-000000000003',
        '00000000-0000-0000-0000-000000000003',
        'user3@example.com',
        'Mike Johnson',
        'user',
        true,
        NOW(),
        NOW()
    ),
    (
        '00000000-0000-0000-0000-000000000004',
        '00000000-0000-0000-0000-000000000004',
        'user4@example.com',
        'Sarah Williams',
        'user',
        true,
        NOW(),
        NOW()
    ),
    (
        '00000000-0000-0000-0000-000000000005',
        '00000000-0000-0000-0000-000000000005',
        'user5@example.com',
        'David Brown',
        'user',
        true,
        NOW(),
        NOW()
    ); 