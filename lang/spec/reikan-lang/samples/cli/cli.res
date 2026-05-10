resource module cli.resources;

import cli.types;

// The CLI tool has minimal resource requirements.
// It runs in a single thread with a small stack.

profile CliProfile {
    memory:      8mb;
    cpu:         scalar_cpu;
    no_swap:     true;
    stack_size:  512kb;
    max_threads: 1;
}
