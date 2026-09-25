```
  # Manually execute logs:
  kubectl exec -it -n ecommerce deployment/order-service -- sh
  echo '{"service": "manual-exec-test", "action": "injected_log", "status": "200", "message": "Hello from inside the pod!"}'
  exit
```
