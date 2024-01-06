import Foundation

/// Initializes CucumberLite configuration
class Config: TestConfiguration {
    static var mediatorOobUrl: String = ""
    static var agentUrl: String = ""
    static var publishedDid: String = ""
    static var jwtSchemaGuid: String = ""
    static var anoncredDefinitionGuid: String = ""
    static var apiKey: String = ""
    
    override class func createInstance() -> ITestConfiguration {
        return Config()
    }
    
    override func targetDirectory() -> URL {
        return URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Target")
    }
    
    override func createActors() async throws -> [Actor]  {
        let cloudAgent = Actor("Cloud Agent").whoCanUse(OpenEnterpriseAPI.self)
        let edgeAgent = Actor("Edge Agent").whoCanUse(Sdk.self )
        return [cloudAgent, edgeAgent]
    }
    
    override func setUp() async throws {
        Config.mediatorOobUrl = environment["MEDIATOR_OOB_URL"]!
        Config.agentUrl = environment["PRISM_AGENT_URL"]!
        Config.publishedDid = environment["PUBLISHED_DID"] ?? ""
        Config.jwtSchemaGuid = environment["JWT_SCHEMA_GUID"] ?? ""
        Config.anoncredDefinitionGuid = environment["ANONCRED_DEFINITION_GUID"] ?? ""
        Config.apiKey = environment["APIKEY"] ?? ""
        
        try await checkPublishedDid()
        try await checkJwtSchema()
        try await checkAnoncredDefinition()
        
        print("Mediator", Config.mediatorOobUrl)
        print("Agent", Config.agentUrl)
        print("DID", Config.publishedDid)
        print("JWT Schema", Config.jwtSchemaGuid)
        print("Anoncred Definition", Config.anoncredDefinitionGuid)
        // TODO: Get SDK version
    }
    
    override func tearDown() async throws {
    }
    
    private func checkPublishedDid() async throws {
        let api = OpenEnterpriseAPI.API()
        let isPresent = try await api.isDidPresent(Config.publishedDid)
        if (isPresent) {
            return
        }
        print("DID [\(Config.publishedDid)] not found. Creating a new one.")
        
        let unpublishedDid = try await api.createUnpublishedDid()
        let publishedDid = try await api.publishDid(unpublishedDid.longFormDid)
        let shortFormDid = publishedDid.scheduledOperation.didRef
        
        try await Wait.until(timeout: 60) {
            let did = try await api.getDid(shortFormDid)
            return did.status == "PUBLISHED"
        }
        
        Config.publishedDid = shortFormDid
    }
    
    private func checkJwtSchema() async throws {
        let api = OpenEnterpriseAPI.API()
        let isPresent = try await api.isJwtSchemaGuidPresent(Config.jwtSchemaGuid)
        if (isPresent) {
            return
        }
        print("JWT schema [\(Config.jwtSchemaGuid)] not found. Creating a new one.")
        
        let jwtSchema = try await api.createJwtSchema(author: Config.publishedDid)
        Config.jwtSchemaGuid = jwtSchema.guid
    }
    
    private func checkAnoncredDefinition() async throws {
        let api = OpenEnterpriseAPI.API()
        let isPresent = try await api.isAnoncredDefinitionPresent(Config.anoncredDefinitionGuid)
        if (isPresent) {
            return
        }
        print("Anoncred Definition not found for [\(Config.anoncredDefinitionGuid)]. Creating a new one.")
        
        let anoncredSchema = try await api.createAnoncredSchema(Config.publishedDid)
        let anoncredDefinition = try await api.createAnoncredDefinition(Config.publishedDid, anoncredSchema.guid)
        Config.anoncredDefinitionGuid = anoncredDefinition.guid
    }
}

enum ConfigError: Error {
    case PublishedDIDNotFound
}
