place custom tiny whisper model in the custom_tiny_whisper_model directory as pytorch_model.bin.

You can safe your custom whisper model via:

```
whisper_model.save_pretrained(<PATH>, safe_serialization=False)
```