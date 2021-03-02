# Script that reads hadolint output and converts to junit xml.
# Output is formatted so Azure Pipelines correctly formats
# errors and links to context information.
import json
from junit_xml import TestSuite, TestCase
import sys

raw_input = sys.stdin.read()
if len(raw_input) == 0:
    exit(0)
input = json.loads(raw_input)

test_cases = []

for entry in input:
    location = f"{entry['file']}:{entry['line']}:{entry['column']}"

    # Azure DevOps JUnit field mapping: https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/test/publish-test-results?view=azure-devops&tabs=junit%2Cyaml
    test_case = TestCase(
        name=f"{entry['code']}: {entry['message']}",
        classname=entry['file'],
        line=entry['line']
    )

    test_case.add_failure_info(
        message=entry['message'],
        output=location,
        failure_type="DockerLinter"
    )

    test_cases.append(test_case)

ts = TestSuite("Docker File Linter", test_cases)
print(TestSuite.to_xml_string([ts]))
with open('hadolint-testresults.xml', 'w') as f:
    TestSuite.to_file(f, [ts], prettyprint=False)
