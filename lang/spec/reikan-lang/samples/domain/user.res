resource module user.resources;

import user.types;

// ──────────────────────────────────────────
// Capability profiles
// ──────────────────────────────────────────

profile UserServiceProfile {
    memory:   128mb;
    cpu:      low_latency;
    no_swap:  true;
    max_heap: 64mb;
}

// ──────────────────────────────────────────
// Resource bindings
// ──────────────────────────────────────────

// Primary database — fulfills the UserRepository contract.
bind postgres UserDb {
    pool_size:       10;
    max_connections: 50;
    connect_timeout: 5s;
    idle_timeout:    60s;
    profile:         UserServiceProfile;
}

// Read-through cache — reduces DB load for find operations.
bind redis UserCache {
    ttl:         3600s;
    max_entries: 100000;
    eviction:    lru;
}
