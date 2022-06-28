version: 2.1

orbs:
  node: circleci/node@4.1
  docker: circleci/docker@1.6.0

jobs:
  build-and-push:
    environment:
      DOCKER_IMAGE: myapp
      DOCKER_TAG: latest
    executor: docker/docker
    steps:
      - setup_remote_docker
      - checkout
      - docker/check:
          docker-username: DOCKER_USER
          docker-password: DOCKER_PASSWORD
      - docker/build:
          image: $DOCKER_USER/$DOCKER_IMAGE
          tag: $DOCKER_TAG

      - docker/push:
          digest-path: /tmp/digest.txt
          image: $DOCKER_USER/$DOCKER_IMAGE
          tag: $DOCKER_TAG
      - run:
          command: |
            echo "Digest is: $(</tmp/digest.txt)"
  deploy:
    executor: docker/docker
    steps:
      - add_ssh_keys:
          fingerprints:
            - $SSH_KEY_FINGERPRINT
      - run: ssh -oStrictHostKeyChecking=no $DEPLOYED_USER@$DEPLOYED_SERVER './deploy.sh'
workflows:
  commit:
    jobs:
      - node/test
      - build-and-push:
          requires:
            - "node/test"
          filters:
            branches:
              only:
                - master
      - deploy:
         requires:
          - build-and-push