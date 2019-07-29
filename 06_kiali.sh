#################################################
# Uninstall 
#################################################

bash <(curl -L https://git.io/getLatestKialiOperator) --uninstall-mode true 
 
#################################################
# Install 
################################################# 

bash <(curl -L https://git.io/getLatestKialiOperator) --accessible-namespaces '**' 

# Forward ports
kubectl port-forward --address 0.0.0.0 svc/kiali 20001:20001 -n istio-system 


# Then the URL is https://10.210.9.140:20001/kiali. 
 