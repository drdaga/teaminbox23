<template>
  <div class="column content-box">
    <woot-button
      color-scheme="success"
      class-names="button--fixed-right-top"
      icon="add-circle"
      @click="openAddPopup"
    >
      {{ buttonText }}
    </woot-button>
    <campaign />
    <woot-modal :show.sync="showAddPopup" :on-close="hideAddPopup">
      <add-campaign @on-close="hideAddPopup" />
    </woot-modal>
  </div>
</template>

<script>
import campaignMixin from 'shared/mixins/campaignMixin';
import Campaign from './Campaign.vue';
import AddCampaign from './AddCampaign';

export default {
  components: {
    Campaign,
    AddCampaign,
  },
  mixins: [campaignMixin],
  data() {
    return { showAddPopup: false };
  },
  computed: {
    buttonText() {
      return this.$t('CAMPAIGN.HEADER_BTN_TXT.WHATSAPP');
    },
  },
  mounted() {
    this.$store.dispatch('campaigns/get');
  },
  methods: {
    openAddPopup() {
      this.showAddPopup = true;
    },
    hideAddPopup() {
      this.showAddPopup = false;
    },
  },
};
</script>
