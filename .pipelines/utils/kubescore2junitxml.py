# Script that reads kubescore output and converts to junit xml.
# Output is formatted so Azure Pipelines correctly formats
# errors and links to context information.
import json
from junit_xml import TestSuite, TestCase
import sys

raw_input = sys.stdin.read()
if len(raw_input) == 0:
    exit(0)
input = json.loads(raw_input)
if not input:
    exit(0)

test_cases = []

for entry in input:
    # Remove absolute path prefix so Azure DevOps recognizes the path correctly.
    entry['file_name'] = entry['file_name'].removeprefix('/src/')

    location = f"{entry['file_name']}:{entry['file_row']}"

    for check in entry['checks']:
        check_name = check['check']['name']

        # Azure DevOps JUnit field mapping: https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/test/publish-test-results?view=azure-devops&tabs=junit%2Cyaml
        test_case = TestCase(
            name=f"{check_name}",
            classname=entry['file_name'],
            line=entry['file_row'],
            allow_multiple_subelements=True
        )

        # If there's no comments, the test passed.
        if check['comments']:
            for comment in check['comments']:

                if check['skipped']:
                    test_case.add_skipped_info(
                        message=comment['summary']
                    )
                else:
                    test_case.add_failure_info(
                        message=comment['description'],
                        output=location,
                        failure_type="KubeScore"
                    )

        # Add the test case regardless of outcome.
        test_cases.append(test_case)

ts = TestSuite("Kubernetes YAML Linter", test_cases)
print(TestSuite.to_xml_string([ts]))
with open('kubescore-testresults.xml', 'w') as f:
    TestSuite.to_file(f, [ts], prettyprint=False)
