#!/bin/bash
set -e

REKERNEL_TAG="11.0"
REKERNEL_X_TAG="1.4"
REKERNEL_DIR="/tmp/ReKernel"
REKERNEL_X_DIR="/tmp/ReKernel_X"

# Clean up any previous runs
rm -rf "$REKERNEL_DIR" "$REKERNEL_X_DIR" drivers/rekernel drivers/rekernel_x

git clone --depth 1 --branch "${REKERNEL_TAG}" https://github.com/Sakion-Team/Re-Kernel "$REKERNEL_DIR"
git clone --depth 1 --branch "${REKERNEL_X_TAG}" https://github.com/myflavor/ReKernel-X "$REKERNEL_X_DIR"

echo "Copying Re-Kernel..."
cp -r "$REKERNEL_DIR"/LKM-Source drivers/rekernel
sed -i 's/depends on MODULES/depends on KSU/' drivers/rekernel/Kconfig
sed -i 's/obj-m := rekernel.o/obj-$(CONFIG_REKERNEL) += rekernel.o/' drivers/rekernel/Makefile

if ! grep -q "obj-\$(CONFIG_REKERNEL) += rekernel/" drivers/Makefile; then
    echo 'obj-$(CONFIG_REKERNEL) += rekernel/' >> drivers/Makefile
fi

if ! grep -q 'source "drivers/rekernel/Kconfig"' drivers/Kconfig; then
    sed -i '/endmenu/i source "drivers/rekernel/Kconfig"' drivers/Kconfig
fi

echo "Copying ReKernel-X..."
cp -r "$REKERNEL_X_DIR"/LKM-Source drivers/rekernel_x
sed -i 's/\bstart_rekernel\b/rkx_start/g; s/\bexit_rekernel\b/rkx_exit/g; s/\bsendMessage\b/rkx_sendMessage/g; s/\bnet_uid_add\b/rkx_net_uid_add/g; s/\bnet_uid_del\b/rkx_net_uid_del/g; s/\bregister_signal\b/rkx_register_signal/g; s/\bunregister_signal\b/rkx_unregister_signal/g; s/\bregister_netfilter\b/rkx_register_netfilter/g; s/\bunregister_netfilter\b/rkx_unregister_netfilter/g; s/\bregister_binder\b/rkx_register_binder/g; s/\bunregister_binder\b/rkx_unregister_binder/g' drivers/rekernel_x/*.c drivers/rekernel_x/*.h 2>/dev/null || true
sed -i 's/obj-m += rekernel_x.o/obj-y += rekernel_x.o/' drivers/rekernel_x/Makefile

if ! grep -q "obj-y += rekernel_x/" drivers/Makefile; then
    echo 'obj-y += rekernel_x/' >> drivers/Makefile
fi

echo "Successfully applied ReKernel and ReKernel-X!"
