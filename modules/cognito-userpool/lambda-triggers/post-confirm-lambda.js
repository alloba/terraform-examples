const AWS = require('aws-sdk');

module.exports.addUserToGroup = (event, context, callback) => {

    const cognitoidentityserviceprovider = new AWS.CognitoIdentityServiceProvider();
    const params = {
        GroupName: 'users', //The name of the group in you cognito user pool that you want to add the user to
        UserPoolId: event.userPoolId,
        Username: event.userName
    };
    //some minimal checks to make sure the user was properly confirmed
    if(! (event.request.userAttributes["cognito:user_status"] === "CONFIRMED" ) ){
        callback("User was not properly confirmed and/or email not verified")
    }

    cognitoidentityserviceprovider.adminAddUserToGroup(params, function(err, data) {
        if (err) {
            callback(err) // an error occurred
        }
        callback(null, event); // successful response
    });
};