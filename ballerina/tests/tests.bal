// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;
import ballerina/oauth2;
import ballerina/http;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

OAuth2RefreshTokenGrantConfig auth = {
       clientId: clientId,
       clientSecret: clientSecret,
       refreshToken: refreshToken,
       credentialBearer: oauth2:POST_BODY_BEARER
};

ConnectionConfig config = {auth:auth};
final Client baseClient = check new Client(config);

//Create a new Cart
@test:Config {}
isolated function testCreateCart() {

    SimplePublicObjectInputForCreate payload = {
      "properties": {
        "hs_cart_name": "Optic",
        "hs_external_cart_id": "1234567890",
        "hs_external_status": "pending",
        "hs_source_store": "XYZ - USA",
        "hs_total_price": "500",
        "hs_currency_code": "USD",
        "hs_cart_discount": "12",
        "hs_tax": "36.25",
        "hs_shipping_cost": "0",
        "hs_tags": "frames, lenses"
      }
    };

    SimplePublicObject|error response =  baseClient ->/carts.post(payload = payload);
    if response is SimplePublicObject{
      test:assertTrue(response?.id !is "");
    }
    else{
      test:assertFail("Error occured while creating a new cart");
    }   
}

//Get all carts
@test:Config {}
isolated function testGetAllCarts() {

  CollectionResponseSimplePublicObjectWithAssociationsForwardPaging|error  response = baseClient ->/carts;

  if response is CollectionResponseSimplePublicObjectWithAssociationsForwardPaging{
    test:assertTrue(response.results.length() > 0);
  }
  else{
    test:assertFail("Error occured while fetching carts");
  } 
};

//Get Cart by Id
@test:Config {}
isolated function testGetCartByID() {

  string cartId = "394588289922";

  SimplePublicObjectWithAssociations|error response = baseClient->/carts/[cartId]();
  if response is SimplePublicObjectWithAssociations{
    test:assertTrue(response?.id == cartId);
  }
  else{
    test:assertFail("Error occured while fetching a cart by cart id : " + cartId);
  }
}

//Update a Cart
@test:Config {}
isolated function testUpdateCart() {

  SimplePublicObjectInput payload = {
    "properties": {
    "hs_tax": "48.75"
    }
  };

  string cartId = "394588289922";

  SimplePublicObject|error response = baseClient->/carts/[cartId].patch(payload =payload);

  if response is SimplePublicObject{
    test:assertTrue(response?.id == cartId);
    test:assertEquals(response?.properties["hs_tax"], payload.properties["hs_tax"]);
  }
  else{
    test:assertFail("Error occured while updating a cart");
  }
}

//Create a new Batch
@test:Config{}
isolated function testCreateBatch() {
  BatchInputSimplePublicObjectInputForCreate payload = {
      "inputs": [
        {
          "properties": {
            "hs_source_store": "ABC Cafe - USA",
            "hs_total_price": "500",
            "hs_currency_code": "USD",
            "hs_tax": "36.25",
            "hs_tags": "donuts, bagels"
          }
        }
      ]
    };

  BatchResponseSimplePublicObject|error response = baseClient->/carts/batch/create.post(payload);

  if response is BatchResponseSimplePublicObject{
    test:assertTrue(response.results[0]["id"] !is "");
  }
  else{
    test:assertFail("Error occured while creating a new batch");
  }
}

//Read a batch
@test:Config{}
isolated function testReadBatch() {

  BatchReadInputSimplePublicObjectId payload ={
    "inputs": [
      {
         "id": "394954883139"
      }
    ],
    "properties": [
      "hs_total_price",
      "hs_currency_code"
    ]
  };

  BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors|error  response = baseClient->/carts/batch/read.post(payload);

  if response is BatchResponseSimplePublicObject{
    test:assertEquals(response.results[0]["id"],payload.inputs[0]["id"]);
  }
  else {
    test:assertFail("Error occurred while reading a batch");
  }
}

//Update a Batch
@test:Config{}

isolated function testUpdateBatch() {
  BatchInputSimplePublicObjectBatchInput payload ={
    "inputs": [
      {
        "id": "394954883139",
        "properties": {
          "hs_source_store": "Cat Cafe - Portland",
          "hs_total_price": "543",
          "hs_currency_code": "GBR"
        }
      }
    ]
  };

  BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors|error response = baseClient->/carts/batch/update.post(payload);

  if response is BatchResponseSimplePublicObject{
    test:assertEquals(response.results[0]["id"],payload.inputs[0]["id"]);
    test:assertEquals(response.results[0]["properties"]["hs_source_store"],payload.inputs[0]["properties"]["hs_source_store"]);
    test:assertEquals(response.results[0]["properties"]["hs_total_price"],payload.inputs[0]["properties"]["hs_total_price"]);
    test:assertEquals(response.results[0]["properties"]["hs_currency_code"],payload.inputs[0]["properties"]["hs_currency_code"]); 
  }
  else {
    test:assertFail("Error occurred while updating a batch");
  }
}

//Upsert a Batch 
@test:Config{}
isolated function testUpsertBatch() {

  BatchInputSimplePublicObjectBatchInputUpsert payload = {
      "inputs": [
      {
        "idProperty": "custom_hs_cart_url",
        "id": "https://app.hubspot.com/contacts/48569051/record/0-142/3395263845436",
        "properties": {
          "hs_source_store": "Cat Cafe - Portland",
          "hs_total_price": "544",
          "hs_currency_code": "USD"
        }
      }
    ]
  };
  
  BatchResponseSimplePublicUpsertObject|BatchResponseSimplePublicUpsertObjectWithErrors|error response =  baseClient->/carts/batch/upsert.post(payload);

  if response is BatchResponseSimplePublicUpsertObject {
    test:assertEquals(response.results[0]["properties"]["hs_source_store"],payload.inputs[0]["properties"]["hs_source_store"]);
    test:assertEquals(response.results[0]["properties"]["hs_total_price"],payload.inputs[0]["properties"]["hs_total_price"]);
    test:assertEquals(response.results[0]["properties"]["hs_currency_code"],payload.inputs[0]["properties"]["hs_currency_code"]);
  }
  else {
    test:assertFail("Error occurred while upserting");
  }
}

//Serch a cart
@test:Config{}
isolated function testSearchCarts() {
  
  PublicObjectSearchRequest payload = {
    "filterGroups": [
      {
        "filters": [
          {
            "propertyName": "hs_source_store",
            "value": "Dog Cafe - Italy",
            "operator": "EQ"
          }
        ]
      }
    ],
    "properties": ["hs_external_cart_id", "hs_source_store"]
  };

  CollectionResponseWithTotalSimplePublicObjectForwardPaging|error response = baseClient->/carts/search.post(payload);

  if response is CollectionResponseWithTotalSimplePublicObjectForwardPaging {
    test:assertTrue(response.total != 0);
  }
  else {
    test:assertFail("Error occurred while searching a batch");
  }
}

//Archive a Batch
@test:Config{}
isolated function testArchiveBatch() {

  BatchInputSimplePublicObjectId payload = {
      "inputs": [
      {
        "id": "395023608593"
      }
    ]
  };

  http:Response|error response =  baseClient->/carts/batch/archive.post(payload);

  if response is http:Response{
    test:assertTrue(response.statusCode is 204);
  }
  else {
    test:assertFail("Error occurred while archiving batch");
  }
}

//Delete a cart
@test:Config{}
isolated function testDeleteCart() {

  string cartId = "394799506036";

  http:Response|error response = baseClient->/carts/[cartId].delete();

  if response is http:Response{
    test:assertTrue(response.statusCode is 204);
  }
  else {
    test:assertFail("Error occurred while deleting cart");
  }
}