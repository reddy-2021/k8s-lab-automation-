#!/bin/bash
set -euo pipefail

SSH_USER="${SSH_USER:-ubuntu}"
SSH_KEY="${HOME}/.ssh/id_rsa"

MASTER_IP=$(head -n1 inventory/master)

echo "========================================"
echo "Getting join command from Master..."
echo "========================================"

JOIN_CMD=$(ssh -i "$SSH_KEY" \
    -o StrictHostKeyChecking=no \
    ${SSH_USER}@${MASTER_IP} \
    "sudo kubeadm token create --print-join-command")

echo "$JOIN_CMD"

echo
echo "========================================"
echo "Joining Worker Nodes"
echo "========================================"

while read -r WORKER
do
    [ -z "$WORKER" ] && continue

    echo "Joining Worker: $WORKER"

    ssh -i "$SSH_KEY" \
        -o StrictHostKeyChecking=no \
        ${SSH_USER}@${WORKER} <<EOF

sudo kubeadm reset -f
sudo $JOIN_CMD

EOF

    echo "Worker $WORKER joined successfully."
    echo
done < inventory/workers

echo "========================================"
echo "All workers joined successfully."
echo "========================================"
