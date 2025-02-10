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
                    script {
                        sh '''
                        scp .env root@134.209.242.198:/root/.env || true
                        ssh root@134.209.242.198 <<EOF
                        docker pull ${bookaroo_image}:latest
                        docker stop bookaroo || true
                        docker rm bookaroo || true
                        docker run -d --name bookaroo -p 3000:3000 --env-file /root/.env ${bookaroo_image}:latest
                        EOF
                        '''
                    }
                }
            }
        }
    }
}
