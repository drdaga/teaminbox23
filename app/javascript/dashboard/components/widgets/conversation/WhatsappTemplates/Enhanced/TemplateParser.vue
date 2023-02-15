<template>
  <div class="medium-12 columns">
    <textarea
      v-if="templateHeader && templateHeader.format === 'TEXT'"
      v-model="processedHeaderString"
      rows="4"
      readonly
      class="template-input"
    />

    <div v-if="headerVariables" class="template__variables-container">
      <p class="variables-label">
        {{ $t('WHATSAPP_TEMPLATES.PARSER.VARIABLES_LABEL') }}
      </p>
      <div
        v-for="(variable, key) in processedHeaderParams"
        :key="key"
        class="template__variable-item"
      >
        <span class="variable-label">
          {{ key }}
        </span>
        <woot-input
          v-model="processedHeaderParams[key]"
          type="text"
          class="variable-input"
          :styles="{ marginBottom: 0 }"
        />
      </div>
      <p v-if="$v.$dirty && $v.$invalid" class="error">
        {{ $t('WHATSAPP_TEMPLATES.PARSER.FORM_ERROR_MESSAGE') }}
      </p>
    </div>

    <div v-if="headerHasMedia" class="">
      <p class="variables-label">{{ templateHeader.format }}</p>
      <woot-input v-model.trim="headerMediaUrl" type="url" name="url" />
      <p v-if="$v.$dirty && $v.$invalid" class="error">
        {{ $t('WHATSAPP_TEMPLATES.PARSER.FORM_ERROR_URL') }}
      </p>
    </div>
    <textarea
      v-model="processedBodyString"
      rows="4"
      readonly
      class="template-input"
    />
    <div v-if="bodyVariables" class="template__variables-container">
      <p class="variables-label">
        {{ $t('WHATSAPP_TEMPLATES.PARSER.VARIABLES_LABEL') }}
      </p>
      <div
        v-for="(variable, key) in processedBodyParams"
        :key="key"
        class="template__variable-item"
      >
        <span class="variable-label">
          {{ key }}
        </span>
        <woot-input
          v-model="processedBodyParams[key]"
          type="text"
          class="variable-input"
          :styles="{ marginBottom: 0 }"
        />
      </div>
      <p v-if="$v.$dirty && $v.$invalid" class="error">
        {{ $t('WHATSAPP_TEMPLATES.PARSER.FORM_ERROR_MESSAGE') }}
      </p>
    </div>
    <footer>
      <woot-button variant="smooth" @click="$emit('resetTemplate')">
        {{ $t('WHATSAPP_TEMPLATES.PARSER.GO_BACK_LABEL') }}
      </woot-button>
      <woot-button v-if="!insideCampaign" @click="sendMessage">
        {{ $t('WHATSAPP_TEMPLATES.PARSER.SEND_MESSAGE_LABEL') }}
      </woot-button>
    </footer>
  </div>
</template>

<script>
const allKeysRequired = value => {
  const keys = Object.keys(value);
  return keys.every(key => value[key]);
};
import { requiredIf, url } from 'vuelidate/lib/validators';
export default {
  props: {
    template: {
      type: Object,
      default: () => {},
    },
    insideCampaign: {
      type: Boolean,
      default: false,
    },
  },
  validations: {
    processedBodyParams: {
      requiredIfKeysPresent: requiredIf('bodyVariables'),
      allKeysRequired,
    },
    processedHeaderParams: {
      requiredIfKeysPresent: requiredIf('headerVariables'),
      allKeysRequired,
    },
    headerMediaUrl: {
      requiredIfKeysPresent: requiredIf('headerHasMedia'),
      url,
    },
  },
  data() {
    return {
      processedBodyParams: {},
      processedHeaderParams: {},
      headerMediaUrl: '',
    };
  },
  computed: {
    bodyVariables() {
      return this.templateBodyString.match(/{{([^}]+)}}/g);
    },
    templateBodyString() {
      return this.template.components.find(
        component => component.type === 'BODY'
      ).text;
    },
    processedBodyString() {
      return this.templateBodyString.replace(
        /{{([^}]+)}}/g,
        (match, variable) => {
          const variableKey = this.processVariable(variable);
          return this.processedBodyParams[variableKey] || `{{${variable}}}`;
        }
      );
    },
    headerVariables() {
      return this.templateHeaderString?.match(/{{([^}]+)}}/g);
    },
    templateHeaderString() {
      return this.template.components.find(
        component => component.type === 'HEADER'
      )?.text;
    },
    templateHeader() {
      return this.template.components.find(
        component => component.type === 'HEADER'
      );
    },
    processedHeaderString() {
      return this.templateHeaderString?.replace(
        /{{([^}]+)}}/g,
        (match, variable) => {
          const variableKey = this.processVariable(variable);
          return this.processedHeaderParams[variableKey] || `{{${variable}}}`;
        }
      );
    },
    headerHasMedia() {
      return this.templateHeader && this.templateHeader.format !== 'TEXT';
    },
  },
  mounted() {
    this.generateBodyVariables();
    this.generateHeaderVariables();
  },
  methods: {
    getPayload() {
      this.$v.$touch();
      if (this.$v.$invalid) return;
      return {
        message: this.processedBodyString,
        templateParams: {
          name: this.template.name,
          category: this.template.category,
          language: this.template.language,
          namespace: this.template.namespace,
          processed_params: {
            header: this.processedHeaderParams,
            headerMedia: {
              link: this.headerMediaUrl,
              type: this.templateHeader?.format,
            },
            headerText: this.processedHeaderString,
            body: this.processedBodyParams,
          },
          components: { ...this.template.components },
        },
      };
    },
    sendMessage() {
      const payload = this.getPayload();
      this.$emit('sendMessage', payload);
    },
    processVariable(str) {
      return str.replace(/{{|}}/g, '');
    },
    generateBodyVariables() {
      const matchedVariables = this.bodyVariables;
      if (!matchedVariables) return;

      const variables = matchedVariables.map(i => this.processVariable(i));
      this.processedBodyParams = variables.reduce((acc, variable) => {
        acc[variable] = '';
        return acc;
      }, {});
    },
    generateHeaderVariables() {
      const matchedVariables = this.headerVariables;
      if (!matchedVariables) return;

      const variables = matchedVariables.map(i => this.processVariable(i));
      this.processedHeaderParams = variables.reduce((acc, variable) => {
        acc[variable] = '';
        return acc;
      }, {});
    },
  },
};
</script>

<style scoped lang="scss">
.template__variables-container {
  padding: var(--space-one);
}

.variables-label {
  font-size: var(--font-size-small);
  font-weight: var(--font-weight-bold);
  margin-bottom: var(--space-one);
}

.template__variable-item {
  align-items: center;
  display: flex;
  margin-bottom: var(--space-one);

  .label {
    font-size: var(--font-size-mini);
  }

  .variable-input {
    flex: 1;
    font-size: var(--font-size-small);
    margin-left: var(--space-one);
  }

  .variable-label {
    background-color: var(--s-75);
    border-radius: var(--border-radius-normal);
    display: inline-block;
    font-size: var(--font-size-mini);
    padding: var(--space-one) var(--space-medium);
  }
}

footer {
  display: flex;
  justify-content: flex-end;

  button {
    margin-left: var(--space-one);
  }
}

.error {
  background-color: var(--r-100);
  border-radius: var(--border-radius-normal);
  color: var(--r-800);
  padding: var(--space-one);
  text-align: center;
}

.template-input {
  background-color: var(--s-25);
}
</style>