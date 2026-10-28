-- OPTIONAL demo data so the dashboard is not empty. Do NOT run this on a live system.
USE campus_feedback;

INSERT INTO feedback (category, rating, comments, status, created_at) VALUES
('Teaching',       5, 'The lectures in the data structures course are clear and well paced. More live coding examples would be even better.', 'Reviewed', NOW() - INTERVAL 9 DAY),
('Infrastructure', 2, 'The Wi-Fi in the second-floor classrooms drops every few minutes during lectures.', 'Pending',  NOW() - INTERVAL 8 DAY),
('Library',        4, 'Great collection of reference books. Please extend the opening hours during exam weeks.', 'Pending',  NOW() - INTERVAL 6 DAY),
('Cleanliness',    1, 'The washrooms near the canteen are not cleaned often enough.', 'Pending',  NOW() - INTERVAL 5 DAY),
('Other',          3, 'Parking space for bicycles is too small in the morning.', 'Reviewed', NOW() - INTERVAL 3 DAY),
('Teaching',       4, 'Faculty are approachable. Lab sessions could use newer equipment.', 'Pending',  NOW() - INTERVAL 2 DAY),
('Infrastructure', 3, 'Projectors in rooms 204 and 206 need repair.', 'Pending',  NOW() - INTERVAL 1 DAY);
