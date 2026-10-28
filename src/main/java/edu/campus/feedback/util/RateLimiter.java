package edu.campus.feedback.util;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

/**
 * Small in-memory sliding-window limiter. Keys (such as an IP address) are
 * kept only in memory and are never written to the database, so feedback
 * stays anonymous.
 */
public final class RateLimiter {

    private final int maxEvents;
    private final long windowMillis;
    private final ConcurrentMap<String, Deque<Long>> events =
        new ConcurrentHashMap<>();

    public RateLimiter(int maxEvents, long windowMillis) {
        this.maxEvents = maxEvents;
        this.windowMillis = windowMillis;
    }

    private void prune(Deque<Long> queue, long now) {
        while (!queue.isEmpty() && now - queue.peekFirst() > windowMillis) {
            queue.pollFirst();
        }
    }

    /** True when the key has already used up its allowance. */
    public boolean isBlocked(String key) {
        Deque<Long> queue = events.get(key);
        if (queue == null) {
            return false;
        }
        long now = System.currentTimeMillis();
        synchronized (queue) {
            prune(queue, now);
            return queue.size() >= maxEvents;
        }
    }

    /** Records one event for the key. */
    public void record(String key) {
        long now = System.currentTimeMillis();
        Deque<Long> queue =
            events.computeIfAbsent(key, k -> new ArrayDeque<>());
        synchronized (queue) {
            prune(queue, now);
            queue.addLast(now);
        }
        if (events.size() > 10_000) {
            events.entrySet().removeIf(entry -> {
                synchronized (entry.getValue()) {
                    prune(entry.getValue(), now);
                    return entry.getValue().isEmpty();
                }
            });
        }
    }

    public void clear(String key) {
        events.remove(key);
    }
}
