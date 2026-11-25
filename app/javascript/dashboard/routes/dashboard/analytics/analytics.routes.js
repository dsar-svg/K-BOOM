import { frontendURL } from '../../../helper/URLHelper';
import Analytics from './Analytics.vue';

export const DASHBOARD_PERMISSIONS = ['administrator', 'report_manage'];

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/analytics'),
      name: 'kaboom_analytics',
      meta: {
        permissions: DASHBOARD_PERMISSIONS,
      },
      component: Analytics,
    },
  ],
};
