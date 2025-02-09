pipeline {
    agent any

    environment {
        bookaroo_image = "mlrdevs/rails-app"
    }

    stages {
        stage('Run Tests') {
            steps {
                sh 'bundle install'
                sh 'RAILS_ENV=test bundle exec rspec'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $bookaroo_image:latest .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                    sh 'docker push $bookaroo_image:latest'
                }
            }
        }

        stage('Deploy') {
            steps {
                sshagent(['vps-ssh-key']) {
                    sh '''
                    ssh root@134.209.242.198 <<EOF
                    docker pull $bookaroo_image:latest
                    docker stop rails-app || true
                    docker rm rails-app || true
                    docker run -d --name rails-app -p 3000:3000 --env-file .env $bookaroo_image:latest
                    EOF
                    '''
                }
            }
        }
    }
}
