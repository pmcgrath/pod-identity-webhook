KUBESCAPE_FAILURE_THRESHOLD=1


kubescape-check:
	@# See https://github.com/armosec/kubescape
	@helm template --api-versions autoscaling/v2 --api-versions policy/v1/PodDisruptionBudget . | \
		kubescape scan framework armobest,mitre,nsa --fail-threshold ${KUBESCAPE_FAILURE_THRESHOLD} -

kubescape-checki-with-exceptions:
	@# See https://github.com/armosec/kubescape
	@# See https://github.com/armosec/kubescape/tree/master/examples/exceptions - docs seem to be out of date
	@#	Can use controlId and wildcards not working as descriped hence - could not use wildcard for job names
	@helm template --api-versions autoscaling/v2 --api-versions policy/v1/PodDisruptionBudget . | \
		kubescape scan framework armobest,mitre,nsa --exceptions ./kubescape-exceptions.json --fail-threshold ${KUBESCAPE_FAILURE_THRESHOLD} -

template:
	@helm template --api-versions autoscaling/v2 --api-versions policy/v1/PodDisruptionBudget .
