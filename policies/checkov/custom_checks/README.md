# Checkov Custom Checks

This directory contains custom Checkov policies for additional compliance checks beyond the built-in rules.

## Structure

```
custom_checks/
├── __init__.py
├── CKV_CUSTOM_*.py    # Custom check implementations
└── README.md
```

## Creating Custom Checks

```python
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
from checkov.common.models.enums import CheckCategories, CheckResult

class MyCustomCheck(BaseResourceCheck):
    def __init__(self):
        name = "Ensure my custom requirement"
        id = "CKV_CUSTOM_1"
        supported_resources = ['aws_s3_bucket']
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        # Return CheckResult.PASSED or CheckResult.FAILED
        return CheckResult.PASSED

check = MyCustomCheck()
```

## Running Custom Checks

```bash
checkov -d . --external-checks-dir policies/checkov/custom_checks
```
