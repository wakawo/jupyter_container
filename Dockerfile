FROM tensorflow/tensorflow:1.8.0-gpu-py3
MAINTAINER kohei

RUN apt-get update

# g++ etc.
RUN apt-get install -y g++
RUN apt-get install -y gdb
RUN apt-get install -y make
RUN apt-get install -y cmake

# wget, curl
RUN apt-get install -y wget
RUN apt-get install -y curl

# git
RUN apt-get install -y git

# opencv
RUN pip install opencv-python
RUN apt update && apt install -y libsm6 libxext6
RUN apt-get install libxrender1
RUN pip install opencv-contrib-python

# tensorflow, keras
RUN pip install --upgrade pip
RUN pip install keras

# scikit-learn
RUN pip install scikit-learn

# XGBoost(gradient boosting tree)
RUN pip install XGBoost

# yaml
RUN pip install pyyaml

# tensorbord
RUN pip install tensorboard

# Flask
RUN pip install Flask

# icrawler
RUN pip install icrawler

# seaborn
RUN pip install seaborn

# jupyter
RUN pip install jupyter
RUN mkdir ~/.jupyter/custom
COPY config_jupyter.css /root/.jupyter/custom/custom.css
EXPOSE 8899
EXPOSE 9988
CMD jupyter notebook --port=8899 --allow-root --ip=0.0.0.0

# work dir
RUN mkdir work
WORKDIR work
