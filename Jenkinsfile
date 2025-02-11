pipeline {
    agent any

    environment {
        bookaroo_image = "mlrdevs/bookaroo"
    }

    stages {
        stage('Checkout from GitHub') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'github_key', keyFileVariable: 'SSH_KEY')]) {
                    sh '''
                    eval $(ssh-agent -s)
                    ssh-add $SSH_KEY || exit 1
                    # Check if the directory already exists and is a git repo
                    if [ -d "bookaroo/.git" ]; then
                        cd bookaroo && git pull
                    else
                        git clone git@github.com:mlrcodes/bookaroo.git
                    fi
                    '''
                }
            }
        }

        stage('Install dependencies') {
            steps {
                sh 'bundle install'
            }
        }
        
        stage('Run Tests') {
            steps {
                sh '''
                    export RAILS_ENV=test
                    bundle exec rspec
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker images | grep ${bookaroo_image} && docker rmi $(docker images ${bookaroo_image} -q) || true
                docker build -t ${bookaroo_image}:latest .
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: 'https://index.docker.io/v1/']) {
                    sh "docker push ${bookaroo_image}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                sshagent(['vps-ssh-key']) {
                    withCredentials([
                        string(credentialsId: 'MONGO_ATLAS_URL', variable: 'MONGO_ATLAS_URL'),
                        string(credentialsId: 'SECRET_KEY_BASE', variable: 'SECRET_KEY_BASE')
                    ]) {
                        script {
                            sh '''
                            ssh root@134.209.242.198 <<EOF
                            docker pull ${bookaroo_image}:latest

                            # Stop and remove the existing container if it exists
                            docker stop bookaroo || true
                            docker rm bookaroo || true

                            # Run new container with environment variables
                            docker run -d --name bookaroo -p 3000:3000 \
                                -e SECRET_KEY_BASE=${SECRET_KEY_BASE} \
                                -e MONGO_ATLAS_URL=${MONGO_ATLAS_URL} \
                                ${bookaroo_image}:latest
                            EOF
                            '''
                        }
                    }
                }
            }
        }
    }
}
