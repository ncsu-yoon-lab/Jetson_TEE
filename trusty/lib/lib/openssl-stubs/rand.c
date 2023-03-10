/* * Copyright (C) 2008 The Android Open Source Project
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <err.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/types.h>
#include <openssl/rand.h>

#if defined(OPENSSL_IS_BORINGSSL)

#include <lib/rng/trusty_rng.h>

/* CRYPTO_sysrand is called by BoringSSL to obtain entropy from the OS. By
 * default, BoringSSL's RNG calls this function without buffering. */
void CRYPTO_sysrand(uint8_t *out, size_t requested)
{
	if (trusty_rng_secure_rand(out, requested) != NO_ERROR) {
		abort();
	}
}

#else

#include <crypto/rand.h>
#include <trusty_std.h>

extern pid_t gettid(void);

int rand_pool_init(void)
{
    return 1;
}

void rand_pool_cleanup(void)
{
}

void rand_pool_keep_random_devices_open(int keep)
{
}

size_t rand_pool_acquire_entropy(RAND_POOL *pool)
{
    return rand_pool_entropy_available(pool);
}

int rand_pool_add_nonce_data(RAND_POOL *pool)
{
    struct {
        uint64_t time;
        pid_t tid;
    } rinfo;;

    /*
     * Add a high resolution timestamp to
     * ensure that the nonce is unique with high probability for
     * different process instances.
     */
    (void)gettime(1, 1, &rinfo.time);
    rinfo.tid = gettid();

    return rand_pool_add(pool, (unsigned char *)&rinfo, sizeof(rinfo), 0);
}

int rand_pool_add_additional_data(RAND_POOL *pool)
{
    return rand_pool_add_nonce_data(pool);
}

#endif  /* OPENSSL_IS_BORINGSSL */
