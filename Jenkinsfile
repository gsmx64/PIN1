pipeline {
  agent any

  options {
    timeout(time: 2, unit: 'MINUTES')
  }

  environment {
    ARTIFACT_ID = "elbuo8/webapp:${env.BUILD_NUMBER}"
  }
  
  stages {
    stage('Building image') {
      steps {
        sh '''
        docker build -t testapp .
        '''  
      }
    }
    stage('Mocha Tests') {
      steps {
        sh '''
        npm install mocha-junit-reporter --save-dev
        ./node_modules/mocha/bin/mocha test/index.js --reporter mocha-junit-reporter --reporter-options mochaFile=./jenkins-test-results.xml
        '''
      }
    }
    stage('Run tests') {
      steps {
        sh "docker run testapp npm test"
      }
    }    
    stage('Deploy Image') {
      steps {
        sh '''
        docker tag testapp 127.0.0.1:5000/mguazzardo/testapp
        docker push 127.0.0.1:5000/mguazzardo/testapp   
        '''
      }
    }
  }
}


    
  

