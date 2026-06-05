/**
 * Main Techia SDK Class
 */

import { HttpClient, type ClientConfig } from "./client";
import { CandidatesResource } from "./resources/candidates";
import { ApplicationsResource } from "./resources/applications";
import { OffersResource } from "./resources/offers";
import { CommissionsResource } from "./resources/commissions";

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
