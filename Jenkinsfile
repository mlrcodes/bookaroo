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
                    git clone git@github.com:mlrcodes/bookaroo.git
                    '''
                }
            }
        }

        stage('Run Tests') {
            steps {
                sh 'bundle install'
                sh 'RAILS_ENV=test bundle exec rspec'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${bookaroo_image}:latest ."
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
                    sh '''
                    scp .env root@134.209.242.198:/root/.env || true
                    ssh root@134.209.242.198 <<EOF
                    docker pull ${bookaroo_image}:latest
                    docker stop rails-app || true
                    docker rm rails-app || true
                    docker run -d --name rails-app -p 3000:3000 --env-file /root/.env ${bookaroo_image}:latest
                    EOF
                    '''
                }
            }
        }
    }
}
