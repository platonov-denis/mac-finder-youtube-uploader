#!/usr/bin/env python3
"""Creates the Finder Quick Action for YouTube upload."""
import os
import plistlib
import uuid
import subprocess

WORKFLOW_PATH = os.path.expanduser(
    "~/Library/Services/Загрузить на YouTube.workflow/Contents"
)

SHELL_SCRIPT = """for f in "$@"; do
    bash "$HOME/Projects/youtube-uploader/upload.sh" "$f" &
done
"""

def create():
    os.makedirs(WORKFLOW_PATH, exist_ok=True)

    action_uuid = str(uuid.uuid4()).upper()

    workflow = {
        "AMApplicationBuild": "521.1",
        "AMApplicationVersion": "2.10",
        "AMDocumentSpecificationVersion": "0.9",
        "actions": [
            {
                "action": {
                    "AMAccepts": {
                        "Container": "List",
                        "Optional": True,
                        "Types": ["com.apple.cocoa.string"],
                    },
                    "AMActionVersion": "2.0.3",
                    "AMApplication": ["Automator"],
                    "AMParameterProperties": {
                        "COMMAND_STRING": {},
                        "CheckedForUserDefaultShell": {},
                        "inputMethod": {},
                        "shell": {},
                        "source": {},
                    },
                    "AMProvides": {
                        "Container": "List",
                        "Types": ["com.apple.cocoa.string"],
                    },
                    "ActionBundlePath": "/System/Library/Automator/Run Shell Script.action",
                    "ActionName": "Run Shell Script",
                    "ActionParameters": {
                        "COMMAND_STRING": SHELL_SCRIPT,
                        "CheckedForUserDefaultShell": True,
                        "inputMethod": 1,
                        "shell": "/bin/bash",
                        "source": "",
                    },
                    "BundleIdentifier": "com.apple.RunShellScript",
                    "CFBundleVersion": "2.0.3",
                    "CanShowSelectedItemsWhenRun": False,
                    "CanShowWhenRun": True,
                    "Category": ["AMCategoryUtilities"],
                    "Class Name": "RunShellScriptAction",
                    "InputUUID": str(uuid.uuid4()).upper(),
                    "Keywords": ["Shell", "Script", "Command", "Run", "Unix"],
                    "OutputUUID": str(uuid.uuid4()).upper(),
                    "UUID": action_uuid,
                    "UnlocalizedApplications": ["Automator"],
                    "arguments": {
                        "0": {
                            "default value": 0,
                            "name": "inputMethod",
                            "required": "0",
                            "type": "0",
                            "uuid": "0",
                        },
                        "1": {
                            "default value": "",
                            "name": "source",
                            "required": "0",
                            "type": "0",
                            "uuid": "1",
                        },
                    },
                    "isViewVisible": True,
                    "location": "309.000000:253.000000",
                    "nibPath": "/System/Library/Automator/Run Shell Script.action/Contents/Resources/English.lproj/main.nib",
                },
                "isViewVisible": True,
            }
        ],
        "connectors": {},
        "workflowMetaData": {
            "serviceInputTypeIdentifier": "com.apple.Automator.fileSystemObject",
            "serviceOutputTypeIdentifier": "com.apple.Automator.nothing",
            "serviceProcessesInput": 0,
            "systemImageName": "NSActionTemplate",
            "useAutomaticInputType": False,
            "workflowTypeIdentifier": "com.apple.Automator.servicesMenu",
        },
    }

    wflow_path = os.path.join(WORKFLOW_PATH, "document.wflow")
    with open(wflow_path, "wb") as f:
        plistlib.dump(workflow, f, fmt=plistlib.FMT_XML)

    info = {
        "NSServices": [
            {
                "NSMenuItem": {"default": "Загрузить на YouTube"},
                "NSMessage": "runWorkflowAsService",
                "NSSendTypes": ["NSFilenamesPboardType"],
            }
        ]
    }
    info_path = os.path.join(WORKFLOW_PATH, "Info.plist")
    with open(info_path, "wb") as f:
        plistlib.dump(info, f, fmt=plistlib.FMT_XML)

    # Register the service
    subprocess.run(["/System/Library/CoreServices/pbs", "-update"], check=False)

    print("Quick Action создан: ~/Library/Services/Загрузить на YouTube.workflow")
    print("Если пункт не появился в Finder — выйди и войди в систему (или перезапусти Finder).")

if __name__ == "__main__":
    create()
