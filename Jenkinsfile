pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'blue-green-app'
        BLUE_PORT = '8081'
        GREEN_PORT = '8082'
        SWITCH = 'blue' // Default deployment environment
    }
    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/mukesh-tp/DevOpsFinal.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }
        stage('Deploy to Blue/Green') {
            steps {
                script {
                    // Check which environment is running
                    def blue_status = sh(script: "./health_check.sh | grep 'Blue is healthy'", returnStatus: true)
                    def green_status = sh(script: "./health_check.sh | grep 'Green is healthy'", returnStatus: true)

                    // Determine which environment to deploy to
                    if (green_status == 0) {
                        SWITCH = 'blue'
                    } else if (blue_status == 0) {
                        SWITCH = 'green'
                    }
                    
                    echo "Deploying to ${SWITCH} environment"
                    
                    // Deploy to Blue or Green
                    if (SWITCH == 'blue') {
                        sh 'docker-compose up -d blue'
                    } else {
                        sh 'docker-compose up -d green'
                    }
                }
            }
        }
        stage('Health Check') {
            steps {
                script {
                    def check = sh(script: "./health_check.sh", returnStatus: true)
                    if (check != 0) {
                        error("Deployment failed during health check.")
                    }
                }
            }
        }
        stage('Switch Traffic') {
            steps {
                script {
                    // Direct traffic to the new environment
                    if (SWITCH == 'blue') {
                        sh 'docker stop green_app || true'
                        echo 'Switched traffic to Blue environment'
                    } else {
                        sh 'docker stop blue_app || true'
                        echo 'Switched traffic to Green environment'
                    }
                }
            }
        }
    }
    post {
        always {
            echo "Cleaning up old containers"
            sh 'docker system prune -f'
        }
    }
}

