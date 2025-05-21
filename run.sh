minikube start --memory=8192 --cpus=5

kubectl apply -f zookeeper-setup.yaml

# sleep 120

echo "Done with zookeeper"

kubectl apply -f ./kafka-setup.yaml

# sleep 120

echo "Done with kafka-setup"

helm install my-neo4j-release neo4j/neo4j -f neo4j-values.yaml
kubectl apply -f neo4j-service.yaml

# sleep 120

echo "Done with neo4j"

kubectl apply -f kafka-neo4j-connector.yaml

sleep 240

echo "Done with kafka connector"

kubectl port-forward svc/neo4j-service 7474:7474 7687:7687 &
kubectl port-forward svc/kafka-service 9092:9092 &

python data_producer.py

echo "Starting TESTER: "

python tester.py
