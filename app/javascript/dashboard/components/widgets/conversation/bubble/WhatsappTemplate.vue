<template>
  <div class="message-text__wrap">
    <div class="text-content">
      <template v-if="templateParams.headerText">
        <p class="header__text">
          {{ templateParams.headerText }}
        </p>
      </template>

      <template v-if="templateParams.headerMedia">
        <template v-if="templateParams.headerMedia.type === 'IMAGE'">
          <img
            :src="templateParams.headerMedia.link"
            alt=""
            class="image-preview"
          />
        </template>

        <template v-if="templateParams.headerMedia.type === 'VIDEO'">
          <video preload="metadata" class="video-placeholder">
            <source :src="templateParams.headerMedia.link" type="video/mp4" />
          </video>
        </template>

        <template v-if="templateParams.headerMedia.type === 'DOCUMENT'">
          <img
            src="/dashboard/images/document-preview.webp"
            alt=""
            class="doc-preview"
          />
        </template>
      </template>

      <!-- Start Body old-->
      <div v-dompurify-html="message" />
      <!-- End Body old -->

      <template v-for="(component, index) in templateComponents">
        <div
          v-if="component.type === 'BUTTONS'"
          :key="index"
          class="template__buttons"
        >
          <template v-for="(button, btnIndex) in component.buttons">
            <template v-if="button.type === 'QUICK_REPLY'">
              <button :key="btnIndex" class="btn_quick_reply">
                {{ button.text }}
              </button>
            </template>
            <template v-if="button.type === 'URL'">
              <a
                :key="btnIndex"
                target="_blank"
                :href="button.url"
                class="footer_url"
              >
                {{ button.text }}
              </a>
            </template>
            <template v-if="button.type === 'PHONE_NUMBER'">
              <a
                :key="btnIndex"
                target="_blank"
                :href="`tel:+${button.phone_number}`"
                class="footer_url"
              >
                {{ button.text }}
              </a>
            </template>
          </template>
        </div>

        <template v-if="component.type === 'FOOTER'">
          <p :key="index" class="footer__text">{{ component.text }}</p>
        </template>
      </template>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    message: {
      type: String,
      default: '',
    },
    data: {
      type: Object,
      default: {},
    },
  },
  computed: {
    templateComponents() {
      return this.data?.additional_attributes?.template_params?.components;
    },
    templateParams() {
      return this.data?.additional_attributes?.template_params.processed_params;
    },
  },
};
</script>
<style lang="scss">
.text-content {
  overflow: auto;

  ul,
  ol {
    padding-left: var(--space-two);
  }

  table {
    all: revert;

    td {
      all: revert;
    }

    tr {
      all: revert;
    }
  }

  h1,
  h2,
  h3,
  h4,
  h5,
  h6 {
    font-size: var(--font-size-normal);
  }
}
.header__text,
.footer__text {
  font-weight: bold;
  margin-bottom: 10px;
}

.image-preview,
.video-placeholder {
  object-fit: cover;
  width: 100%;
  margin: 0 auto 10px;
  height: 150px;
}

.doc-preview {
  object-fit: contain;
  margin: auto;
  display: block;
}

.template__buttons {
  margin: 10px 0;
  display: flex;
  gap: 10px;
}

.footer_url,
.btn_quick_reply {
  margin-bottom: 10px;
  background-color: #f1f1f1;
  padding: 8px 10px;
  border-radius: 4px;
  font-weight: bold;
  color: #000 !important;
  text-decoration: none !important;
}
</style>
