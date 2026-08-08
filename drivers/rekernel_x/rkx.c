/*
 * Copyright (c) 2026 myflavor <admin@myflv.cn>. All rights reserved.
 * Based on Re-Kernel project by nep_timeline@outlook.com.
 * File: rkx.c — Module entry (init/exit) & hooks wiring.
 */

#include "rkx_log.h"
#include "rkx.h"
#include <linux/printk.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/tracepoint.h>

static int __init rkx_start(void)
{
	rkx_log_info("starting...\n");
	rkx_log_debug("Debug mode is enabled!\n");
	rkx_log_info("Version %s |  by myflavor, Sakion Team\n", RKX_VERSION);

	init_net_uid();
	init_free_async();

	if (register_genl() != LINE_SUCCESS)
	{
		rkx_log_err("%s: Failed to register genl family!\n", __func__);
		goto err;
	}

	rkx_log_info("start hooking!\n");

	if (rkx_register_binder() != LINE_SUCCESS)
	{
		rkx_log_err("%s: Failed to hook binder!\n", __func__);
		goto err;
	}

	if (rkx_register_signal() != LINE_SUCCESS)
	{
		rkx_log_err("%s: Failed to hook signal!\n", __func__);
		goto err;
	}

	if (rkx_register_netfilter() != LINE_SUCCESS)
	{
		rkx_log_err("%s: Failed to hook netfilter!\n", __func__);
		goto err;
	}

	register_binder_kp();

	rkx_log_info("hooked!\n");
	return LINE_SUCCESS;

err:
	unregister_binder_kp();
	rkx_unregister_netfilter();
	rkx_unregister_signal();
	rkx_unregister_binder();
	tracepoint_synchronize_unregister();
	unregister_genl();
	destroy_free_async();
	destroy_net_uid();
	return LINE_ERROR;
}

static void __exit rkx_exit(void)
{
	rkx_log_info("closing...\n");
	unregister_binder_kp();
	rkx_unregister_netfilter();
	rkx_unregister_signal();
	rkx_unregister_binder();
	tracepoint_synchronize_unregister();
	unregister_genl();
	destroy_free_async();
	destroy_net_uid();
}

module_init(rkx_start);
module_exit(rkx_exit);

MODULE_LICENSE("GPL");
