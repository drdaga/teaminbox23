<template>
  <div class="medium-12 columns">
    <div class="templates__list-search">
      <fluent-icon icon="search" class="search-icon" size="16" />
      <input
        ref="search"
        v-model="query"
        type="search"
        :placeholder="$t('WHATSAPP_TEMPLATES.PICKER.SEARCH_PLACEHOLDER')"
        class="templates__search-input"
      />
    </div>
    <div class="template__list-container">
      <div v-for="template in filteredTemplateMessages" :key="template.id">
        <button
          class="template__list-item"
          @click="$emit('onSelect', template)"
        >
          <div>
            <div class="flex-between">
              <span class="label-lang label">
                {{ $t('WHATSAPP_TEMPLATES.PICKER.LABELS.NAME') }} :
                {{ template.name }}
              </span>
              <span class="label-lang label">
                {{ $t('WHATSAPP_TEMPLATES.PICKER.LABELS.LANGUAGE') }} :
                {{ template.language }}
              </span>
            </div>

            <div>
              <span class="label-category label">
                {{ $t('WHATSAPP_TEMPLATES.PICKER.LABELS.CATEGORY') }} :
                {{ template.category }}
              </span>
            </div>
            <!-- Start Components -->
            <div v-for="(component, index) in template.components" :key="index">
              <div
                v-if="component.type === 'HEADER'"
                class="template__list-item__box"
              >
                <div class="template__list-item__header">
                  <p class="strong">
                    {{ $t('WHATSAPP_TEMPLATES.PICKER.LABELS.TEMPLATE_HEADER') }}
                  </p>
                  <p class="label-body">{{ component.format }}</p>
                </div>
              </div>

              <div
                v-if="component.type === 'BODY'"
                class="template__list-item__box"
              >
                <div class="template__list-item__body">
                  <p class="strong">
                    {{ $t('WHATSAPP_TEMPLATES.PICKER.LABELS.TEMPLATE_BODY') }}
                  </p>
                  <p class="label-body">{{ component.text }}</p>
                </div>
              </div>

              <div
                v-if="component.type === 'BUTTONS'"
                class="template__list-item__box"
              >
                <p class="strong">
                  {{ $t('WHATSAPP_TEMPLATES.PICKER.LABELS.TEMPLATE_BUTTONS') }}
                </p>
                <div
                  v-for="(button, index) in component.buttons"
                  :key="index"
                  class="template__list-item__buttons"
                >
                  <span class="template__list-item__buttons__btn">{{
                    button.text
                  }}</span>
                </div>
              </div>

              <div
                v-if="component.type === 'FOOTER'"
                class="template__list-item__box"
              >
                <div class="template__list-item__footer">
                  <p class="strong">
                    {{ $t('WHATSAPP_TEMPLATES.PICKER.LABELS.TEMPLATE_FOOTER') }}
                  </p>
                  <p class="label-body">{{ component.text }}</p>
                </div>
              </div>
            </div>
            <!-- End Components -->
          </div>
        </button>
      </div>
      <div v-if="!filteredTemplateMessages.length">
        <p>
          {{ $t('WHATSAPP_TEMPLATES.PICKER.NO_TEMPLATES_FOUND') }}
          <strong>{{ query }}</strong>
        </p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    inboxId: {
      type: Number,
      default: undefined,
    },
  },
  data() {
    return {
      query: '',
    };
  },
  computed: {
    whatsAppTemplateMessages() {
      return this.$store.getters['inboxes/getWhatsAppTemplates'](this.inboxId);
    },
    filteredTemplateMessages() {
      return this.whatsAppTemplateMessages.filter(template =>
        template.name.toLowerCase().includes(this.query.toLowerCase())
      );
    },
  },
};
</script>

<style scoped lang="scss">
.flex-between {
  display: flex;
  justify-content: space-between;
  margin-bottom: var(--space-one);
}

.templates__list-search {
  align-items: center;
  background-color: var(--s-25);
  border-radius: var(--border-radius-medium);
  border: 1px solid var(--s-100);
  display: flex;
  margin-bottom: var(--space-one);
  padding: 0 var(--space-one);

  .search-icon {
    color: var(--s-400);
  }

  .templates__search-input {
    background-color: transparent;
    border: var(--space-large);
    font-size: var(--font-size-mini);
    height: unset;
    margin: var(--space-zero);
  }
}

.template__list-container {
  // background-color: var(--s-25);
  border-radius: var(--border-radius-medium);
  max-height: 30rem;
  overflow-y: auto;
  padding: var(--space-one);

  & > div {
    &:not(:last-of-type) {
      margin-bottom: 15px;
    }
  }

  .template__list-item {
    border-radius: var(--border-radius-medium);
    cursor: pointer;
    display: block;
    padding: var(--space-two);
    text-align: left;
    width: 100%;
    background-color: var(--s-25);
    box-shadow: 0px 5px 11px 0 rgb(116 116 116 / 30%);
    border: 1px solid #e9e9e9;

    &:hover {
      background-color: var(--w-50);
    }

    &__buttons {
      display: inline-block;
      margin-right: 10px;
      margin-bottom: 10px;
      margin-top: 10px;

      &__btn {
        background-color: #ddd;
        border-radius: 3px;
        display: inline-block;
        padding: 10px 15px;
        font-size: 12px;
      }
    }

    &__box {
      border: 1px solid #ddd;
      padding: 20px;
      border-radius: 4px;
      margin-bottom: 10px;
    }

    .label-title {
      font-size: var(--font-size-small);
    }

    // .label-category {
    //   margin-top: var(--space-two);

    //   span {
    //     font-size: var(--font-size-small);
    //     font-weight: var(--font-weight-bold);
    //   }
    // }

    .label-category {
      margin-bottom: var(--space-two);
    }
    .label-body {
      font-family: monospace;
    }
  }
}

.strong {
  font-size: var(--font-size-mini);
  font-weight: var(--font-weight-bold);
}

hr {
  border-bottom: 1px solid var(--s-100);
  margin: var(--space-one) auto;
  max-width: 95%;
}
</style>
