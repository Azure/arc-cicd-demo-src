# Script that reads yamllint output and converts to junit xml.
# Output is formatted so Azure Pipelines correctly formats
# errors and links to context information.
import re
import sys
from junit_xml import TestSuite, TestCase

# Parses Yamllint output with the --format=parsable flag.
YAMLLINT_PARSABLE_REGEX = r'^(?P<location>(?P<filename>.*):(?P<line_number>\d+):\d+): \[(?P<severity>\w+)\] (?P<description>.*) \((?P<code>[\w-]+)\)$'

test_cases = []

for line in sys.stdin:
    match = re.match(YAMLLINT_PARSABLE_REGEX, line)

    # Azure DevOps JUnit field mapping: https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/test/publish-test-results?view=azure-devops&tabs=junit%2Cyaml
    test_case = TestCase(
        name=f"{match.group('code')}: {match.group('description')}",
        classname=match.group('filename'),
        line=match.group('line_number')
    )

    test_case.add_failure_info(
        message=match.group('description'),
        output=match.group('location'),
        failure_type="yamllint"
    )

    test_cases.append(test_case)

ts = TestSuite("Yamllint YAML Linter", test_cases)
print(TestSuite.to_xml_string([ts]))
with open('yamllint-testresults.xml', 'w') as f:
    TestSuite.to_file(f, [ts], prettyprint=False)
