resource module server.resources;

import server.types;

// ──────────────────────────────────────────
// Capability profiles
// ──────────────────────────────────────────

profile HttpServerProfile {
    memory:          256mb;
    cpu:             low_latency;
    no_swap:         true;
    max_heap:        192mb;
    max_threads:     64;
    io_model:        async_io_uring;
}

profile RequestHandlerProfile {
    memory:          4mb;
    cpu:             low_latency;
    no_swap:         true;
    stack_size:      64kb;
}

// ──────────────────────────────────────────
// Default server configuration
// ──────────────────────────────────────────

// The ServerConfig is declared as a named type in server.types.
// The production configuration is bound here and injected at startup.
bind config ServerDefaults {
    host:            "127.0.0.1";
    port:            8080;
    max_connections: 1000;
    read_timeout:    30000;
    write_timeout:   30000;
}

// ──────────────────────────────────────────
// Downstream dependencies
// ──────────────────────────────────────────

// The HTTP server calls into the user service.
// Its resource binding is declared in user.resources, not here.
// Cross-service resource profiles are composed at deployment time.
