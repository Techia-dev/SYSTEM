/**
 * Main Techia SDK Class
 */

import { HttpClient, type ClientConfig } from "./client";
import { CandidatesResource } from "./modules/candidates";
import { ApplicationsResource } from "./modules/applications";
import { OffersResource } from "./modules/offers";
import { CommissionsResource } from "./modules/commissions";

export class TechiaSdk {
    private httpClient: HttpClient;

    public candidates: CandidatesResource;
    public applications: ApplicationsResource;
    public offers: OffersResource;
    public commissions: CommissionsResource;

    constructor(config: ClientConfig) {
        this.httpClient = new HttpClient(config);

        // Initialize resource clients
        this.candidates = new CandidatesResource(this.httpClient);
        this.applications = new ApplicationsResource(this.httpClient);
        this.offers = new OffersResource(this.httpClient);
        this.commissions = new CommissionsResource(this.httpClient);
    }

    /**
     * Set authentication token for all subsequent requests
     */
    setAuthToken(token: string): void {
        this.httpClient.setAuthToken(token);
    }

    /**
     * Clear authentication token
     */
    clearAuthToken(): void {
        this.httpClient.clearAuthToken();
    }
}
