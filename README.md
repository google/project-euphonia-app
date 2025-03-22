# Project Euphonia App

Train a personalized speech model that can transcribe your speech better.

Use this mobile app to record at least 100 phrases which can be used  to 
personalize a speech model. This model can be deployed on Google Cloud and 
its endpoint can be used from the app to transcribe your speech. 

### Customizing phrases (Optional)

100 phrases are already present under `assets/phrases.txt`. But you can create 
new or additional phrases using this prompt.

```
Please create a list of 100 short English phrases such that they have good 
distribution of all phonemes and their allophones, try to keep the length of 
each phrase less than 140. Please make sure none of the words in the list are 
repeated more than thrice. All the phrases don't need to be a valid sentence 
either, the important task is to ensure coverage over all phonemes and maintain a 
good distribution of allophones. Please don't add numbering at the beginning of 
the list.
```

You can try it for different language as well!


### Build & Run the app

1. git clone https://github.com/google/project-euphonia-app
2. `cd project-euphonia-app`
3. Run `dart pub global activate flutterfire_cli`
4. Create a project in Firebase.
5. Create firebase storage (not "database", it needs to be "storage"), and turn `false` to `true` under Rules. 
6. `flutterfire configure --project=<project-id>`. Run `firebase projects:list` to get project-id. 
(this will generate access token files to firebase and respective directories)
7. Android app should be now be buildable (use Android studio or `flutter build apk`).
8. For iOS `cd ios` and run `pod install`. Make sure mobile-provisioning profiles are present to install the app on-device.


### Download the speech data

You can download your recorded phrases using the gsutil command
```
gsutil -m cp -R gs://<project-id>.appspot.com .
```


### Train your personalized model

You can train your personalized model using the colab under `training_colabs/Project_Euphonia_Finetuning.ipynb`


### Setup Transcription API

Follow instructions under `api/Readme.md` to deploy the personalized model on Google Cloud Run & obtain a transcription endpoint.
Add the transcription endpoint to the app in `Settings > URL of cloud-run service`.


# Intended Use

Project Euphonia is a set of open-source toolkits intended for use by developers to create and customize speech recognition solutions. It provides tools and documentation for collecting speech data, fine-tuning open-source Automatic Speech Recognition (ASR) models, and deploying those models for speech-to-text transcription.The open-source toolkits, in its original form, is not intended to be used without modification for the diagnosis, treatment, mitigation, or prevention of any disease or medical condition. Developers are solely responsible for making substantial changes to Project Euphonia’s open-source toolkits and for ensuring that any applications they create comply with all applicable laws and regulations, including those related to medical devices.


### Indications for Use:

Project Euphonia’s open-source toolkits is intended to provide developers with the capability to:

- Collect volunteered speech data using a customizable mobile application.
- Fine-tune open-source Automatic Speech Recognition (ASR) models using provided training recipes and infrastructure.
- Deploy trained ASR models for speech-to-text transcription.
- Create accessibility solutions and other applications that leverage customized speech recognition technology.


### Toolkit Description:

Project Euphonia’s open-source toolkits are designed to facilitate the creation of customized speech recognition solutions. The toolkits consists of:
- A Flutter-based mobile application for recording speech data and associating it with text phrases. The application stores data in a Firebase Storage instance controlled by the developer.
- Google Colab notebooks providing example code and documentation for fine-tuning open-source Automatic Speech Recognition (ASR) models. The notebooks will help inform developers on the following topics: data preparation, model training, and performance evaluation.
- Example code for deploying a web service that performs speech-to-text transcription using the fine-tuned ASR models. The web service can be deployed to cloud platforms such as Google Cloud Run.
