#!/usr/bin/env python3
import json
import os
import struct
import sys

YKMA_BIN = "/home/linuxbrew/.linuxbrew/bin/ykman"


def getMessage() -> str:
    rawLength = sys.stdin.buffer.read(4)
    if len(rawLength) == 0:
        sys.exit(0)
    messageLength: int = struct.unpack("@I", rawLength)[0]
    message: str = sys.stdin.buffer.read(messageLength).decode("utf-8")
    return json.loads(message)


def encodeMessage(messageContent: dict) -> dict:
    encodedContent = json.dumps(messageContent).encode("utf-8")
    encodedLength = struct.pack("@I", len(encodedContent))
    return {"length": encodedLength, "content": encodedContent}


def sendMessage(encodedMessage: dict):
    sys.stdout.buffer.write(encodedMessage["length"])
    sys.stdout.buffer.write(encodedMessage["content"])
    sys.stdout.buffer.flush()


def getOtpCode(key: str) -> str:
    result = run(f'{YKMA_BIN} oath accounts code "{key}"')
    # result = run(f'ls')
    return result.strip().split(" ")[-1]


def handleGenerateOtpMessage(receivedMessage: dict):
    responseMessage = {
        "type": "otpResponse",
        "target": receivedMessage["target"],
        "otp": getOtpCode(receivedMessage["keyName"]),
    }
    sendMessage(encodeMessage(responseMessage))


def run(command: str) -> str:
    """Runs a shell command and returns its output."""
    return os.popen(command).read()


while True:
    receivedMessage = getMessage()
    isGenerateOtp = receivedMessage.get("type") == "generateOtp"
    if isGenerateOtp:
        handleGenerateOtpMessage(receivedMessage)
