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
                        echo "Starting deploy process..."
                        
                        # Copy .env file to the VPS
                        scp .env root@134.209.242.198:/root/.env
                        if [ $? -ne 0 ]; then
                            echo "Failed to copy .env file"
                            exit 1
                        fi
                        echo "Env file copied successfully"
                        
                        # SSH into VPS to deploy
                        ssh root@134.209.242.198 <<EOF
                        echo "Pulling Docker image"
                        docker pull ${bookaroo_image}:latest
                        if [ $? -ne 0 ]; then
                            echo "Docker pull failed"
                            exit 1
                        fi
                        echo "Docker image pulled successfully"

                        echo "Checking for existing containers"
                        docker ps -a
                        echo "Stopping existing container"
                        docker stop bookaroo || true
                        echo "Removing existing container"
                        docker rm bookaroo || true

                        echo "Running new container"
                        docker run -d --name bookaroo -p 3000:3000 --env-file /root/.env ${bookaroo_image}:latest
                        if [ $? -ne 0 ]; then
                            echo "Docker run failed"
                            docker logs bookaroo  # Show logs if the container fails to start
                            exit 1
                        fi
                        echo "Container started successfully"
                        EOF
                        '''
                    }
                }
            }
}
    }
}
